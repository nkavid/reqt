find_program(CCACHE_PROGRAM ccache REQUIRED)

set(CCACHE_OPTIONS
  "export CCACHE_DIR=${CMAKE_BINARY_DIR}/ccache
export CCACHE_DEBUG=1
export CCACHE_SLOPPINESS=system_headers"
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/ccache-launcher.in"
  "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/ccache-launcher"
)

execute_process(COMMAND chmod a+rx
  "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/ccache-launcher"
)

set(CMAKE_CXX_COMPILER_LAUNCHER "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/ccache-launcher")
set(CMAKE_C_COMPILER_LAUNCHER "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/ccache-launcher")
