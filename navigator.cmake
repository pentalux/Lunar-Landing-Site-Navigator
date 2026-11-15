# Qt Design Studio may regenerate qds.cmake and module CMakeLists.txt.
# Register only files that the generated module has not registered yet.
get_target_property(navigator_existing HackathonContent SOURCES)
set(navigator_qml
    Navigator.qml MissionController.qml WorkbenchButton.qml PanelHeading.qml
    PropertyRow.qml SitePanel.qml InspectorPanel.qml CompareView.qml
    SceneView.qml OrbitRing.qml HorizonPlot.qml Timeline.qml Mission.js SceneMath.js Terrain.js
    SetupPanel.qml CustomTerrain.qml)
set(navigator_missing)
foreach(navigator_file IN LISTS navigator_qml)
    set(navigator_found FALSE)
    foreach(navigator_source IN LISTS navigator_existing)
        if(navigator_source MATCHES "(^|/)${navigator_file}$")
            set(navigator_found TRUE)
        endif()
    endforeach()
    if(NOT navigator_found)
        set(navigator_path "${CMAKE_CURRENT_SOURCE_DIR}/HackathonContent/${navigator_file}")
        set_source_files_properties("${navigator_path}" PROPERTIES QT_RESOURCE_ALIAS "${navigator_file}")
        list(APPEND navigator_missing "${navigator_path}")
    endif()
endforeach()
if(navigator_missing)
    qt_target_qml_sources(HackathonContent QML_FILES ${navigator_missing})
endif()

# Big resources avoid compiling a 140 MB GLB as a C++ byte array.
file(GLOB navigator_science CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/HackathonContent/assets/science/*")
list(FILTER navigator_science EXCLUDE REGEX "/heights$")
list(FILTER navigator_science EXCLUDE REGEX "/([0-7](-slope)?\\.glb|LandingMeshes\\.js|moon-normals\\.png)$")
list(FILTER navigator_science EXCLUDE REGEX "/moon-(band-|north-|south-)normals\\.png$")
file(GLOB navigator_heights CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/HackathonContent/assets/science/heights/global-*.bin" "${CMAKE_CURRENT_SOURCE_DIR}/HackathonContent/assets/science/heights/south-*.bin")
qt_add_resources(${CMAKE_PROJECT_NAME} navigator_assets
    BIG_RESOURCES
    OPTIONS --compress-algo zlib --compress 9 --threshold 0
    PREFIX "/qt/qml/HackathonContent"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}/HackathonContent"
    FILES
        ${navigator_science}
        ${navigator_heights}
        HackathonContent/assets/lander.glb
        HackathonContent/assets/pin.glb
        HackathonContent/assets/regolith.png
        HackathonContent/assets/regolith-normal.png
        HackathonContent/assets/terrain.glb
        HackathonContent/assets/terrain-slope.glb
        HackathonContent/assets/earth-nasa.jpg
        HackathonContent/assets/moon-nasa.jpg)

