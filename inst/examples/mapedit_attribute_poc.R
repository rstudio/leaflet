library(mapview)
library(listviewer)
library(htmltools)
library(shiny)

lf <- mapview(breweries91)@map

lf_popup <- htmlwidgets::onRender(
  lf,
'
function(el,x) {
  var map = this;
  map.on("popupopen", function(x){
    editpopup(x);
  })
}
'
)

tagList(
  fluidPage(
    fluidRow(
      column(7,lf_popup),
      column(4,listviewer::jsonedit(width="100%", elementId="popup-editor"))
    )
  ),
  tags$script(
'
function editpopup(popup) {
debugger;
  var editor = HTMLWidgets.find("#popup-editor").editor;
  var cells = $("td",popup.popup._contentNode);
  var info = {};

  cells.each(function(i,d){if(i%2===0){info[$(d).text()]=$(cells[i+1]).html()}})

  editor.set(info);
}
'
  )
) %>%
  browsable()
