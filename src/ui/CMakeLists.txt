if(NEXORA_HAS_QT)
    add_library(nexora_ui
        controllers/MainController.cpp
    )
    target_link_libraries(nexora_ui PUBLIC Qt6::Core Qt6::Gui Qt6::Widgets)
    target_include_directories(nexora_ui PUBLIC ${CMAKE_SOURCE_DIR}/src/ui)
    target_compile_definitions(nexora_ui PUBLIC NEXORA_HAS_QT)
else()
    add_library(nexora_ui INTERFACE)
endif()
