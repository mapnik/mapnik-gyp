{
  "target_defaults": {
    "default_configuration": "<(configuration)",
    "msvs_configuration_platform": "<(platform)",
    "msbuild_toolset":"v140",
    "msvs_disabled_warnings": [ 4068,4244,4005,4506,4345,4804,4805,4661 ],
    "msvs_settings": {
      "VCCLCompilerTool": {
        "ObjectFile": "$(IntDir)/%(RelativeDir)/",
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
        "-Wno-c++11-long-long",
        "-Wno-unsequenced",
        "-Wno-sign-compare",
        "-Wno-unused-function",
        "-Wno-redeclared-class-member",
        "-Wno-c99-extensions",
        "-Wno-c++11-extra-semi",
        "-Wno-variadic-macros",
        "-Wno-c++11-extensions",
        "-Wno-unused-const-variable",
        "-Wno-unknown-pragmas",
        "-Wno-c++11-narrowing" # works around boost gil bug
      ]
    },
    "cflags_cc": [
      "-std=c++11",
      "-fPIC", # so that we can link agg into libmapnik.so
      "-Wno-c++11-narrowing", # works around boost gil bug
      "-Wno-unsequenced",
      "-Wno-unknown-pragmas",
      "-Wno-redeclared-class-member"
    ],
    "configurations": {
      "Debug": {
        "defines": [ "DEBUG","_DEBUG" ],
        "msvs_settings": {
          "VCCLCompilerTool": {
            "RuntimeLibrary": "3",
            "Optimization": 0,
            "FavorSizeOrSpeed": 1, # /Ot, favour speed over size
            "MinimalRebuild": "false",
            "OmitFramePointers": "true",
            "BasicRuntimeChecks": 3,
            "AdditionalOptions": [
              "/MP", # compile across multiple CPUs
              "/bigobj", #compiling: x86 fatal error C1128: number of sections exceeded object file format limit: compile with /bigobj
            ],
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
            "RuntimeLibrary": "2", #0:/MT, 2:/MD,
            "Optimization": 3, # /Ox, full optimization
            "FavorSizeOrSpeed": 1, # /Ot, favour speed over size
            "InlineFunctionExpansion": 2, # /Ob2, inline anything eligible
            #"WholeProgramOptimization": "true", # /GL, whole program optimization, needed for LTCG
            "OmitFramePointers": "true",
            #"EnableFunctionLevelLinking": "true",
            "EnableIntrinsicFunctions": "true",
            "AdditionalOptions": [
              "/MP", # compile across multiple CPUs
              "/bigobj", #compiling: x86 fatal error C1128: number of sections exceeded object file format limit: compile with /bigobj
            ],
            "DebugInformationFormat": "3"
          },
          "VCLibrarianTool": {
            "AdditionalOptions": [
              #"/LTCG"
            ],
          },
          "VCLinkerTool": {
            #"LinkTimeCodeGeneration": 1, # link-time code generation
            #"OptimizeReferences": 2, # /OPT:REF
            #"EnableCOMDATFolding": 2, # /OPT:ICF
            "LinkIncremental": 2, # force incremental linking
            "GenerateDebugInformation": "true",
            "AdditionalOptions": [
                #"/NODEFAULTLIB:libcmt.lib"
            ],
          }
        },
        "xcode_settings": {
          "GCC_OPTIMIZATION_LEVEL": "3",
          "GCC_GENERATE_DEBUGGING_SYMBOLS": "NO",
          "DEAD_CODE_STRIPPING": "YES",
          "GCC_INLINES_ARE_PRIVATE_EXTERN": "YES"
        }
      }
    }
  }
}

