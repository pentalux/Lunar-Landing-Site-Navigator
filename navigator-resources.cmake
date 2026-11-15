# QDS may rediscover the large scientific files when it regenerates its module.
# Keep those files exclusively in navigator.cmake's BIG_RESOURCES target; the
# ordinary generated C++ resource array cannot hold the full offline dataset.
set(navigator_generated_module "${CMAKE_CURRENT_SOURCE_DIR}/HackathonContent/CMakeLists.txt")
file(READ "${navigator_generated_module}" navigator_generated_content)
string(REGEX REPLACE "[\r\n]+[ \t]*\"assets/science/[^\"]+\"" ""
    navigator_filtered_content "${navigator_generated_content}")
if(NOT navigator_filtered_content STREQUAL navigator_generated_content)
    file(WRITE "${navigator_generated_module}" "${navigator_filtered_content}")
endif()

# Preparation-tool dependencies are not application resources in a clean clone.
set(navigator_generated_root "${CMAKE_CURRENT_SOURCE_DIR}/qds.cmake")
file(READ "${navigator_generated_root}" navigator_root_content)
string(REGEX REPLACE "[\r\n]+[ \t]*\"tools/(python-libs|data)/[^\"]+\"" ""
    navigator_filtered_root "${navigator_root_content}")
if(NOT navigator_filtered_root STREQUAL navigator_root_content)
    file(WRITE "${navigator_generated_root}" "${navigator_filtered_root}")
endif()
