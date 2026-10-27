add_executable(Nexora
    main.cpp
    NexoraApplication.cpp
)

target_link_libraries(Nexora PRIVATE
    nexora_core
    nexora_backend
    nexora_ui
)

if(WIN32)
    set_property(TARGET Nexora PROPERTY WIN32_EXECUTABLE ON)
endif()

install(TARGETS Nexora
    RUNTIME DESTINATION bin
    BUNDLE DESTINATION .
    LIBRARY DESTINATION lib
)
