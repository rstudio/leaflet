library(htmltools)
library(leaflet)
library(pipeR)

lf <- leaflet(width="100%") %>% addTiles()

css <- "
html, body {
  height: 100%;
}
body {
padding: 8px;
background-color: #F6F6F6;
box-sizing: border-box;
}
.split {
-webkit-box-sizing: border-box;
-moz-box-sizing: border-box;
box-sizing: border-box;
overflow-y: auto;
overflow-x: hidden;
}
.content {
border: 1px solid #C0C0C0;
box-shadow: inset 0 1px 2px #e4e4e4;
background-color: #fff;
}
.gutter {
background-color: transparent;
background-repeat: no-repeat;
background-position: 50%;
}
.gutter.gutter-horizontal {
cursor: col-resize;
background-image: url('https://cdn.rawgit.com/nathancahill/Split.js/877632e1/grips/vertical.png');
}
.gutter.gutter-vertical {
cursor: row-resize;
background-image: url('https://cdn.rawgit.com/nathancahill/Split.js/877632e1/grips/horizontal.png');
}
.split.split-horizontal, .gutter.gutter-horizontal {
height: 100%;
float: left;
}
"

tagList(
  tags$link(rel="stylesheet", href="https://cdnjs.cloudflare.com/ajax/libs/normalize/3.0.3/normalize.css"),
  tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/split.js/1.2.0/split.min.js"),
  tags$style(css),
  tags$div(
    style = "height:410px;",
    tags$div(
      id = "map1",
      class = "split split-horizontal",
      tags$div(class="split content", lf)
    ),
    tags$div(
      id = "map2",
      class = "split split horizontal",
      tags$div(class="split content", lf)
    )
  ),
  tags$script('
Split(["#map1", "#map2"], {
  gutterSize: 8,
  cursor: "col-resize",
  onDragEnd: function(evt){
    $(".html-widget",$(event.target).parent().parent()).each(function(hw){
      HTMLWidgets.find("#" + this.id).resize()
    })
  }
})
  ')
) %>>%
  browsable()



library(svglite)
svg1 <- htmlSVG({contour(volcano)}, standalone=FALSE)

tagList(
  tags$link(rel="stylesheet", href="https://cdnjs.cloudflare.com/ajax/libs/normalize/3.0.3/normalize.css"),
  tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/split.js/1.2.0/split.min.js"),
  tags$style(css),
  tags$div(
    style = "height:410px;",
    tags$div(
      id = "map1",
      class = "split split-horizontal",
      tags$div(class="split content", lf)
    ),
    tags$div(
      id = "map2",
      class = "split split horizontal",
      tags$div(class="split content", svg1)
    )
  ),
  tags$script('
Split(["#map1", "#map2"], {
  gutterSize: 8,
  cursor: "col-resize",
  onDragEnd: function(evt){
    $(".html-widget",$(event.target).parent().parent()).each(function(hw){
      HTMLWidgets.find("#" + this.id).resize()
    })
  }
})
  ')
  ) %>>%
  browsable()

