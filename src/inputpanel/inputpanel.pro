CONFIG += console

SOURCES += main.cpp \
           testinputpanel.cpp \
           myinputpanelcontext.cpp

HEADERS += testinputpanel.h \
           myinputpanelcontext.h

FORMS   += mainform.ui

# install
target.path = $$[QT_INSTALL_EXAMPLES]/tools/inputpanel
sources.files = $$SOURCES $$HEADERS $$RESOURCES $$FORMS inputpanel.pro
sources.path = $$[QT_INSTALL_EXAMPLES]/tools/inputpanel
INSTALLS += target sources

symbian: include($$QT_SOURCE_TREE/examples/symbianpkgrules.pri)
