# CMakeLists.txt for the PrismQuanta C++ Interface

# Specify the minimum version of CMake required.
cmake_minimum_required(VERSION 3.15)

# Define the project name and specify C++ as the language.
project(PrismQuantaInterface CXX)

# Set the C++ standard to C++17. This gives us access to modern features
# like std::filesystem and structured bindings, which will be useful.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Gather all source and header files
set(SOURCES
    prismquanta_interface.cpp
    Config.cpp
)

# Define the executable target for our application.
add_executable(prismquanta_interface ${SOURCES})

# --- Library Dependencies (Placeholders) ---
# As we build out the application, we will add library dependencies here.
#
# Example for finding and linking an XML parsing library:
# find_package(PugiXML REQUIRED)
# target_link_libraries(prismquanta_interface PRIVATE PugiXML::pugixml)
#
# Example for linking against a local llama.cpp build:
# target_link_libraries(prismquanta_interface PRIVATE /path/to/libllama.a)