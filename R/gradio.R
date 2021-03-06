##' @include GWidget.R
NULL

##' Toolkit  constructor
##'
##' @export
##' @rdname gWidgets2RGtk2-undocumented
##' @method .gradio guiWidgetsToolkitRGtk2
## @export .gradio guiWidgetsToolkitRGtk2
.gradio.guiWidgetsToolkitRGtk2 <-  function(toolkit,
                                            items,selected=1, horizontal=FALSE, handler=NULL,
                                            action=NULL, container=NULL, ...
                                            ) {

  GRadio$new(toolkit, items, selected, horizontal,
             handler, action, container, ...)
}


## radio button class
GRadio <- setRefClass("GRadio",
                      contains="GWidgetWithItems",
                      methods=list(
                        initialize=function(toolkit, items, selected, horizontal,
                          handler, action, container, ...) {
                          widget <<- NULL
                          widgets <<- list()
                          if(horizontal)
                            block <<- gtkHBox()
                          else
                            block <<- gtkVBox()

                          change_signal <<- "toggled"
                          
                          set_items(value=items)
                          set_index(selected)
                          
                          add_to_parent(container, .self, ...)
                          
                          handler_id <<- add_handler_changed(handler, action)
                          
                          callSuper(toolkit)
                        },
                        get_value=function(drop=TRUE, ...) {
                          get_items(get_index())
                        },
                        set_value=function(value, drop=TRUE, ...) {
                          set_index(pmatch(value, get_items()))
                        },
                        get_index = function(...) {
                          which(sapply(widgets, gtkToggleButtonGetActive))
                        },
                        set_index = function(value, ...) {
                          widgets[[value[1]]]$setActive(TRUE)
                        },
                        get_items = function(i, ...) {
                          items <- sapply(widgets, gtkButtonGetLabel)
                          items[i]
                        },
                        set_items = function(value, i, ...) {
                          ## make widgets
                          radiogp <- gtkRadioButton(label=value[1])
                          sapply(value[-1], gtkRadioButtonNewWithLabelFromWidget, 
                                      group = radiogp)
                          widgets <<- rev(radiogp$getGroup())
                          ## pack in widgets
                          sapply(block$getChildren(), gtkContainerRemove, object=block) # remove old
                          sapply(widgets, gtkBoxPackStart, object=block, padding=2)
                          
                          ## add handler to each button to call back to observers
                          sapply(widgets, gSignalConnect, signal="toggled", f = function(self, w, ...) {
                            if(w$getActive())
                              self$notify_observers(signal="toggled", ...)
                          }, data=.self, user.data.first=TRUE)
                          invisible()
                        },
                        get_length=function(...) length(get_items()),
                        get_enabled=function() {block$getSensitive()},
                        set_enabled=function(value) {block$setSensitive(value)},
                        get_visible = function() block$getVisible(),
                        set_visible = function(value) block$setVisible(as.logical(value))
                        ))

