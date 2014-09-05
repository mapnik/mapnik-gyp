{
  "target_defaults": {
    "default_configuration": "Release",
    "msbuild_toolset":"v140",
    "msvs_disabled_warnings": [ 4068,4244,4005,4506,4345,4804,4805,4661 ],
    "msvs_settings": {
      "VCCLCompilerTool": {
        "ExceptionHandling": 1,
        "RuntimeTypeInfo": "true"
      }
    },
    "xcode_settings": {
      "CLANG_CXX_LIBRARY": "libc++",
      "CLANG_CXX_LANGUAGE_STANDARD":"c++11",
      "GCC_VERSION": "com.apple.compilers.llvm.clang.1_0",
      "MACOSX_DEPLOYMENT_TARGET":"10.9",
      "WARNING_CFLAGS": [
        "-Wall",
        "-Wextra",
        "-pedantic",
        "-Wno-parentheses",
        "-Wno-char-subscripts",
        "-Wno-unused-parameter",
        "-Wno-c++11-narrowing",
        "-Wno-c++11-long-long",
        "-Wno-unsequenced",
        "-Wno-sign-compare",
        "-Wno-unused-function",
        "-Wno-redeclared-class-member",
        "-Wno-c99-extensions",
        "-Wno-c++11-extra-semi",
        "-Wno-variadic-macros",
        "-Wno-c++11-extensions",
        "-Wno-unused-const-variable"
      ]
    },
    "cflags_cc": ["-std=c++11"],
    "configurations": {
      "Debug": {
        "defines": [ "DEBUG" ],
        "msvs_settings": {
          "VCCLCompilerTool": {
            "RuntimeLibrary": "3",
            "Optimization": 0,
            "MinimalRebuild": "false",
            "OmitFramePointers": "false",
            "BasicRuntimeChecks": 3
          }
        },
        "xcode_settings": {
          "GCC_OPTIMIZATION_LEVEL": "0",
          "GCC_GENERATE_DEBUGGING_SYMBOLS": "YES"
        }
      },
      "Release": {
        "defines": [ "NDEBUG" ],
        "msvs_settings": {
          "VCCLCompilerTool": {
            "RuntimeLibrary": 0,
            "Optimization": 3,
            "FavorSizeOrSpeed": 1,
            "InlineFunctionExpansion": 2,
            "OmitFramePointers": "true",
            "EnableIntrinsicFunctions": "true",
            "AdditionalOptions": [
              "/MP"
            ],
            "DebugInformationFormat": "0"
          },
          "VCLibrarianTool": {
            "AdditionalOptions": [
              "/LTCG"
            ],
          },
          "VCLinkerTool": {
            "LinkTimeCodeGeneration": 1,
            "LinkIncremental": 2,
            "GenerateDebugInformation": "false"
          }
        },
        "xcode_settings": {
          "GCC_OPTIMIZATION_LEVEL": "3",
          "GCC_GENERATE_DEBUGGING_SYMBOLS": "NO",
          "DEAD_CODE_STRIPPING": "YES",
          "GCC_INLINES_ARE_PRIVATE_EXTERN": "YES"
        }
      },
      "Debug_Win32": {
        'inherit_from': ['Debug'],
        "msvs_configuration_platform": "Win32",
        "defines": [ "_DEBUG"],
      },
      "Debug_x64": {
        'inherit_from': ['Debug'],
        "msvs_configuration_platform": "x64",
        "defines": [ "_DEBUG"],
      },
      "Release_Win32": {
        'inherit_from': ['Release'],
        "msvs_configuration_platform": "Win32"
      },
      "Release_x64": {
        'inherit_from': ['Release'],
        "msvs_configuration_platform": "x64"
      }
    }
  }
}

