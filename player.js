(function() {
  var tag = document.createElement('script');
  tag.src = "//www.youtube.com/iframe_api";
  var firstScriptTag = document.getElementsByTagName('script')[0];
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
})();

function fillContainerWithVideo($container, $video, videoRatio) {
  var containerRatio = $container.width() / $container.height()
  if (videoRatio < containerRatio) {
    var width = $container.width()
    var height = width / videoRatio
    $video.width(width).height(height).css("marginLeft", 0)
  } else {
    var height = $container.height()
    var width = height * videoRatio
    $video.width(width).height(height)

    var widthOverflow = width - $container.width()
    var overFlowPerSide = -widthOverflow / 2
    $video.css("marginLeft", overFlowPerSide + "px")
  }
}

function keepContainerFilledWithVideo($container, $video, videoRatio) {
  var fill = function() {
    fillContainerWithVideo($container, $video, videoRatio)
  }
  $(window).resize(fill)
  fill()
}

function onYouTubeIframeAPIReady() {
  var isMobile = /(iPad|iPhone|iPod|Windows Phone|Android)/g.test(navigator.userAgent)

  if (!isMobile) {
    var $container = $(".player-container")
    var videoId = 'HPnwcLHBZAQ';
    new YT.Player('player', {
      videoId: videoId,
      playerVars: {
        autoplay: 1,
        loop: 1,
        playlist: videoId,
        rel: 0,
        showinfo: 0,
        controls: 0,
        modestbranding: 1
      },
      events: {
        onReady: function(event) {
          var $teaser = $container.find("iframe")
          var teaserVideoRatio = 1920/1080
          keepContainerFilledWithVideo($container, $teaser, teaserVideoRatio)
        }
      }
    });
  }
}
