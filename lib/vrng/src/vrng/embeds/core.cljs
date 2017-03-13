(ns vrng.embeds.core
  (:require
   [vrng.helpers :as helpers :refer [icon]]
   [vrng.sporktrum :as spork]
   [vrng.talk :as talk]
   [vrng.util :as u :refer [t state track-event]]
   [vrng.media :as m]
   [reagent.core :as reagent :refer [atom]]
   [reagent.session :as session]
   [secretary.core :as secretary :include-macros true]
   goog.string.format
   goog.string
   [clojure.string :as str]
   [ajax.core :refer [POST DELETE to-interceptor default-interceptors]]))


(enable-console-print!)

(defonce page-state (atom {:user-name (.-userName js/window)
                           :pin-id (.-pinId js/window)
                           :podcast-url (.-podcastUrl js/window)
                           :itunes-url (.-itunesUrl js/window)
                           ;; this needs to be a comp if not false
                           :popover-message false
                           :popover-share false
                           :width nil
                           :now (js/Date.)}))

(def token 150)
(def tiny 320)
(def xs 480)
(def small 640)
(def medium 1024)

(defn responsive-class-comp []
  "this should return the correct responsive class based on screen width"
  ;(.log js/console (:width @page-state))
  (str (:width @page-state))
  (cond
    (< (:width @page-state) token) "token"
    (< (:width @page-state) tiny) "tiny"
    (< (:width @page-state) xs) "xs"
    (< (:width @page-state) small) "small"
    (< (:width @page-state) medium) "medium"
    (>= (:width @page-state) medium) "large"
    ))

(defonce current-user
  (atom (js->clj (.-currentUser js/window) :keywordize-keys true)))

(defn volume-percentage []
  (m/volume-percentage))

(defn audio-meter-percentage []
  (str (u/percentage (:volume @spork/audio) 255) "%"))

(defn talk [] (:talk @state))

(defn slides-url [] (:slides_url (talk)))

(defn in-talk-state [state-name]
  (= state-name (:state (:talk @state))))

(defn relative-time []
  (u/from-now (u/to-millis (:starts_at (talk)))))

(defn relative-countdown []
  (if (> (:now @page-state) (u/to-millis (:starts_at (talk))))
    "any time now..."
    (relative-time)))


(defn- humanize [num]
  (cond
    (< num 1000) (str num)
    (>= num 1000) (goog.string.format "%.1f k" (/ num 1000))))

(defn humanreadable-plays []
  (humanize (:play_count (talk))))

(defn close-message-action []
  (swap! page-state assoc :popover-message false))

;; COMPS USED IN ACTIONS

(defn more-comp []
  [:div.msg-holder

   [:a.msg-text
    (let [wid (:width @page-state)]
      (cond
        (< wid xs) "More..."
        (< wid small) "More on VR..."
        (< wid medium) "More on Voice Republic..."
        (>= wid medium) "There's more on Voice Republic..."))]
   [:a.action-btn.close-msg
    {:title "Cancel"
     :on-click close-message-action} "×"]])

(defn please-login-comp []
  [:div.msg-holder
   [:a.msg-text {:href "/"}
    [:p
     [:span  "Please log in"]]]
   [:a.action-btn.close-msg
    {:title "Cancel"
     :on-click close-message-action} "×"]
   ])

(defn image-class []
  (if (< (:width @page-state) 900) "small" "big"))

;; ACTIONS

(defn adjust-volume-action [event]
  (.stopPropagation event)
  (u/track-event (str "embedplayer volume talk:" (:id (talk))))
  (let [meter (.-currentTarget event)
        top (.-top (.getBoundingClientRect meter))
        bottom (.-bottom (.getBoundingClientRect meter))
        current (.-clientY event)
        volume (/ (- bottom current) (- bottom top))]
    (m/volume! volume)))

(defn seek-action [event]
  ;;(.log js/console event)
  (.stopPropagation event)
  (if (= (:state (:talk @state)) "archived")
    (let [timeline (.-currentTarget event)
          left (.-left (.getBoundingClientRect timeline))
          right (.-right (.getBoundingClientRect timeline))
          current (.-clientX event)
          requested (/ (- left current) (- left right)) ; 0..1
          time (* (m/duration) requested)] ; in seconds
      ;;(.log js/console timeline left right current requested time)
      (u/track-event (str "embedplayer seek talk:" (:id (talk))))
      (m/seek! time))))

(defn pin-action []
  (track-event "embedtalk pin-this-talk")
  (POST (str "/talks/" (:id (talk)) "/reminders")
        {:handler #(swap! page-state assoc :pin-id (get % "id"))}))

(defn unpin-action []
  (track-event "embedtalk unpin-this-talk")
  (DELETE (str "/reminders/" (:pin-id @page-state))
          {:handler #(swap! page-state assoc :pin-id nil)}))

(defn open-share-action []
  (swap! page-state assoc :popover-share true))

(defn close-share-action []
  (swap! page-state assoc :popover-share false))



(defn pin-anon-action []
  (swap! page-state assoc :popover-message please-login-comp))

(defn play-action [event]
  (.stopPropagation event)
  (track-event (str "embedplayer pause talk:" (:id (talk))))
  (close-message-action)
  (m/play!))

(defn pause-action [event]
  (.stopPropagation event)
  (track-event (str "embedplayer pause talk:" (:id (talk))))
  (swap! page-state assoc :popover-message more-comp)
  (m/pause!))

;; COMPONENTS
(defn responsive-size-display-comp []
  [:span (responsive-class-comp)]
  )

(defn play-pause-button-comp []
  [:div.jp-controls
   {:class (if (in-talk-state "prelive") "disabled" "")}
   (if (:paused @m/state)
     [:a.jp-play {:on-click play-action} [icon "play"]]
     [:a.jp-pause {:on-click pause-action} [icon "pause"]])])

(defn message-comp [nested-comp]
  [:div.embed-msg
   [nested-comp]
   (if-not (:paused @m/state)
     [:a.action-btn.close-msg
      {:title "Cancel"
       :on-click close-message-action} "×"])])

(defn action-panel-comp []
  [:div.action-panel

   ;;SLIDES BUTTON
   (if (slides-url)
     [:a.action-btn.slides-btn
      {:href (:url (talk)) :title "View Slides" :target "_blank"}
      [icon "slides"]])

   [:div.jp-spacer]

   ;;CHAT
   [:a.action-btn.chat-btn
    {:href (:url (talk)) :title "Comment" :target "_blank"}
    [icon "chat"]]

   [:div.jp-spacer]

   ;;PIN
   [:div.pinboard
    (if js/signedIn
      (if (:pin-id @page-state)
        [:button.button.button-playbar.button-unpin
         {:on-click unpin-action} [icon "pin"]]
        [:button.button.button-playbar.button-pin
         {:on-click pin-action} [icon "pin-outline"]])
      [:button.button.button-playbar.button-pin
       {:on-click pin-anon-action} [icon "pin-outline"]])]


   [:div.jp-spacer]

   ;;SHARE
   [:a.action-btn.action-share
    {:title "Share"
     :on-click open-share-action}
    [icon "share"]]])

(defn share-panel-comp []
  [:div.share-panel
   [:div.share-title [:p "share:"]]
   [:div.jp-spacer]
   [:div.action-btn.share.share-btn.twitter
    {:data-shareable-type "talk" :data-shareable-id "3728"}
    [:a
     {:href "#"}
     [icon "twitter"]]]
   [:div.jp-spacer]
   [:div.action-btn.facebook.share.share-btn
    {:data-shareable-type "talk" :data-shareable-id "3728"}
    [:a
     {:href "#"}
     [icon "facebook"]]]
   [:div.jp-spacer]
   [:div.action-btn.mail.share.share-btn
    {:data-shareable-type "talk" :data-shareable-id "3728"}
    [:a
     {:href
      (str "mailto:your@friend.com?"
           "body=Hi%20there%0A%0ACheck%20out%20this%20talk%20on"
           "%20voicerepublic.com%3A%20"
           (:url (:talk @state))
           "%0A%0ABest%20regards%0A"
           (:user-name @page-state)
           "&subject=Check%20out%20this%20talk%20on"
           "%20voicerepublic.com")}
     [icon "email"]]]
   [:div.jp-spacer]
   [:a.action-btn.close-share {:title "Cancel"
                               :on-click close-share-action} "×"]
   [:div.jp-spacer]])

(defn progress-comp []
  [:div.jp-progress
   [:div.jp-seek-bar {:style {:width "100%"}
                      :on-click seek-action}
    [:div.jp-play-bar {:style {:width (str (m/progress-percentage) "%")}}]]
   ;;[:div.loading-indicator
   ;; [:p
   ;;  [:span "Loading"]]]
   (if-not (and (< (:width @page-state) small)
                (:popover-share @page-state))
     [:div.jp-time-holder
      (if (in-talk-state "prelive")
        [:span (relative-countdown)]
        (do
          [:span.jp-current-time (u/format-m-s (m/current-runtime))]
          [:span.time-divider "/"]
          [:span.jp-duration (u/format-m-s (m/duration))]))])])



(defn root-comp []
  [:div.embed-player.clearfix {:class (responsive-class-comp)}

   ;;image
   [:div.image-box ;{:class (image-class)}

    [:a {:href (:url (talk))}
     [:img {:src (:thumb_url (talk))}]]]

   ;; everything else
   [:div.content-box


    ;;title, meta-data, logo
    [:div.top-box.clearfix
     [:div.info-box
      [:a {:href (:url (talk)) :target "_blank"}
       [:h4.title
        (:title (talk))]]
      [:div.meta-info
       [:a.user
        {:href (get-in (talk) [:venue :user :url]) :target "_blank"}
        [:span (get-in (talk) [:venue :user :name])]]
       [:span.date.sm-up " / " (if (in-talk-state "prelive")
                                 (relative-countdown)
                                 (relative-time))]
       (if (in-talk-state "archived")
         [:span.play-count.sm-up " / " (humanreadable-plays) " Plays"])]]
     [:div.branding-box
      [:a {:href (:url (talk)) :target "_blank"}
       [:div.brand-logo [icon "logo"]]
       [:div.brand-words [icon "logotype"]]]]]

    ;;player wrapper
    [:div.player-box

     ;;main UI
     [:div.jp-audio

      ;;player controls
      [:div.jp-gui.jp-interface

       [play-pause-button-comp]

       [:div.jp-spacer]

       ;;volume
       [:div.jp-volume-bar

        {:on-click adjust-volume-action}
        [:div.jp-volume-bar-value
         {:style {:height (volume-percentage)}}]
        [:div.jp-volume-bar-value-dancing
         {:style {:height (audio-meter-percentage)}}]]

       (if-let [message (:popover-message @page-state)]
         [message-comp message]
         [progress-comp])

       [:div.jp-spacer]

       (if (:popover-share @page-state)
         [share-panel-comp]
         [action-panel-comp])]]]]])


(defn mount-root []
  (reagent/render [root-comp] (.getElementById js/document "embedded-player"))
  ;;(reagent/render [m/debug-audio-comp] (.getElementById js/document "debug"))
  )

(defn init! []
  (mount-root))

(talk/init-audio! (:talk @state))

(js/setTimeout #(spork/setup-analyser-for-media-element "audio") 500)

(js/setInterval #(swap! page-state assoc :now (js/Date.)) 1000)

(defn set-size []
  (->> (.-outerWidth js/window)
       (swap! page-state assoc :width)
       (.log js/console (image-class))))


(.addEventListener
  js/window "resize" set-size)

(set-size)
