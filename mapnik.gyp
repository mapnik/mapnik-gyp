{
  "includes": [
    "./common.gypi"
  ],
  "variables": {
    "includes%":"",
    "libs%":"",
    "configuration%":"",
    "platform%":"",
    "common_defines": [
      "BIGINT",
      "BOOST_REGEX_HAS_ICU",
      "HAVE_JPEG",
      "MAPNIK_USE_PROJ4",
      "HAVE_PNG",
      "HAVE_TIFF",
      "HAVE_WEBP",
      "MAPNIK_THREADSAFE",
      "HAVE_CAIRO",
      "GRID_RENDERER",
      "SVG_RENDERER",
      "BOOST_SPIRIT_USE_PHOENIX_V3=1"
    ],
    "common_includes": [
      "../include", # mapnik
      "../deps/", # mapnik/sparsehash
      "../deps/agg/include/", # agg
      "../deps/clipper/include/", # clipper
      "../", # boost shim
      "<@(includes)/",
      "<@(includes)/gdal",
      "<@(includes)/freetype2",
      "<@(includes)/libxml2",
      "<@(includes)/cairo"
    ],
    "boost_version":"1_57",
    "boost_toolset":"vc140",
    "python_version": '<!(python -c "import sys;print(\'%s.%s\' % (sys.version_info.major,sys.version_info.minor))")',
    "python_version2": '<!(python -c "import sys;print(\'%s%s\' % (sys.version_info.major,sys.version_info.minor))")',
    "python_root": '<!(python -c "import sys,ntpath,posixpath;print(sys.prefix).replace(ntpath.sep,posixpath.sep)")', # note: single quotes needed for windows
    "conditions": [
      ["OS=='win'",
        {
          "conditions": [
            ["configuration=='Debug'",
              {
                  "boost_filesystem_lib":"libboost_filesystem-<(boost_toolset)-mt-gd-<(boost_version).lib",
                  "boost_regex_lib":"libboost_regex-<(boost_toolset)-mt-gd-<(boost_version).lib",
                  "boost_system_lib":"libboost_system-<(boost_toolset)-mt-gd-<(boost_version).lib",
                  "boost_thread_lib":"libboost_thread-<(boost_toolset)-mt-gd-<(boost_version).lib",
                  "boost_program_options_lib":"libboost_program_options-<(boost_toolset)-mt-gd-<(boost_version).lib",
                  "boost_python_lib":"boost_python-<(boost_toolset)-mt-gd-<(boost_version).lib",
                  "webp_lib":"libwebp_debug_dll.lib",
                  "icuuc_lib":"icuucd.lib",
                  "icuin_lib":"icuind.lib",
                  "pq_lib":"libpqd.lib"
              },
              {
                  "boost_filesystem_lib":"libboost_filesystem-<(boost_toolset)-mt-<(boost_version).lib",
                  "boost_regex_lib":"libboost_regex-<(boost_toolset)-mt-<(boost_version).lib",
                  "boost_system_lib":"libboost_system-<(boost_toolset)-mt-<(boost_version).lib",
                  "boost_thread_lib":"libboost_thread-<(boost_toolset)-mt-<(boost_version).lib",
                  "boost_program_options_lib":"libboost_program_options-<(boost_toolset)-mt-<(boost_version).lib",
                  "boost_python_lib":"boost_python-<(boost_toolset)-mt-<(boost_version).lib",
                  "webp_lib":"libwebp_dll.lib",
                  "icuuc_lib":"icuuc.lib",
                  "icuin_lib":"icuin.lib",
                  "pq_lib":"libpq.lib"
              }
            ]
          ],
          "common_defines": [
            "LIBXML_STATIC", # static libxml: libxml2_a.lib
            "BOOST_VARIANT_DO_NOT_USE_VARIADIC_TEMPLATES",
            'BOOST_MSVC_ENABLE_2014_JUN_CTP',
            "_WINDOWS"
          ],
          "common_libraries": [],
          "python_includes":"<(python_root)/include",
          "python_libs":"<(python_root)/libs",
          "python_module_extension": "pyd"
        },
        {
          "common_defines": ["SHAPE_MEMORY_MAPPED_FILE","U_CHARSET_IS_UTF8=1"],
          "common_libraries": [
            "-L<@(libs)"
          ],
          "python_includes":"/usr/include/python<(python_version)",
          "python_libs":"<(python_root)/lib",
          "python_module_extension": "so"
        }
      ],
      ["OS=='mac'",
        {
          "common_libraries": [
            "-Wl,-search_paths_first"
          ]
        }
      ],
      ["OS=='linux'",
        {
          "common_libraries": [
            "-pthread",
            "-ldl",
            "-lrt"
          ]
        }
      ]
    ]
  },
  "targets": [
    {
      "target_name": "mapnik-wkt",
      "type": "static_library",
      "sources": [
        "<!@(find ../src/wkt/ -name '*.cpp')"
      ],
      "defines": [
        "<@(common_defines)"
      ],
      "include_dirs":[
        "<@(common_includes)"
      ]
    },
    {
      "target_name": "mapnik-json",
      "type": "static_library",
      "sources": [
        "<!@(find ../src/json/ -name '*.cpp')"
      ],
      "defines": [
        "<@(common_defines)"
      ],
      "include_dirs":[
        "<@(common_includes)"
      ]
    },
    {
      "target_name": "mapnik",
      "product_name": "mapnik",
      "type": "shared_library",
      "product_dir":"lib",
      "sources": [
        "<!@(find ../deps/agg/src/ -name '*.cpp')",
        "<!@(find ../deps/clipper/src/ -name '*.cpp')",
        "<!@(find ../src/agg/ -name '*.cpp')",
        "<!@(find ../src/cairo/ -name '*.cpp')",
        "<!@(find ../src/grid/ -name '*.cpp')",
        "<!@(find ../src/group/ -name '*.cpp')",
        "<!@(find ../src/renderer_common/ -name '*.cpp')",
        "<!@(find ../src/svg/ -name '*.cpp')",
        "<!@(find ../src/text/ -name '*.cpp')",
        "<!@(find ../src/ -name '*.cpp' -maxdepth 1)"
      ],
      "xcode_settings": {
        "SDKROOT": "macosx",
        "SUPPORTED_PLATFORMS":["macosx"],
        "PUBLIC_HEADERS_FOLDER_PATH": "include",
        "OTHER_CPLUSPLUSFLAGS":[
          "-ftemplate-depth-300"
        ],
        "DYLIB_INSTALL_NAME_BASE": "@loader_path"
      },
      "msvs_settings": {
        "VCLinkerTool": {
          "AdditionalLibraryDirectories": [
            "<@(libs)/"
          ]
        }
      },
      "defines": [
        "<@(common_defines)"
      ],
      "libraries": [
        "<@(common_libraries)"
      ],
      "conditions": [
        ["OS=='win'",
          {
            "defines": ["MAPNIK_EXPORTS"],
            "libraries":[
              "<(boost_filesystem_lib)",
              "<(boost_regex_lib)",
              "<(boost_system_lib)",
              "<(webp_lib)",
              "<(icuuc_lib)",
              "<(icuin_lib)",
              "libpng16.lib",
              "proj.lib",
              "libtiff_i.lib",
              "libxml2_a.lib",
              "ws2_32.lib",
              "libjpeg.lib",
              "freetype.lib",
              "zlib.lib",
              "cairo.lib",
              "harfbuzz.lib"
            ]
          },
          {
            "libraries":[
              "-lboost_filesystem",
              "-lboost_regex",
              "-lboost_system",
              "-lcairo",
              "-lpixman-1",
              "-lexpat",
              "-lpng",
              "-lproj",
              "-ltiff",
              "-lwebp",
              "-lxml2",
              "-licui18n",
              "-ljpeg",
              "-licuuc",
              "-lfreetype",
              "-licudata",
              "-lharfbuzz",
              "-lz"
            ]
          }
        ]
      ],
      "include_dirs":[
        "<@(common_includes)"
      ],
      "direct_dependent_settings": {
        "include_dirs": [
          "<@(common_includes)"
        ],
        "defines": [
          "<@(common_defines)"
        ],
        "libraries":[
          "<@(common_libraries)"
        ],
        "msvs_settings": {
          "VCLinkerTool": {
            "AdditionalLibraryDirectories": [
              "<@(libs)/"
            ]
          }
        }
      }
    },
    {
      "target_name": "_mapnik",
      "product_prefix":"",
      "product_dir":"lib/python<(python_version)/mapnik/",
      "type": "loadable_module",
      "product_extension": "<(python_module_extension)",
      "sources": [ "<!@(find ../bindings/python/ -name '*.cpp')" ],
      "dependencies": [ "mapnik", "mapnik-wkt", "mapnik-json" ],
      "copies": [
        {
          "files": [ "../bindings/python/mapnik/__init__.py" ],
          "destination": "<(PRODUCT_DIR)/lib/python<(python_version)/mapnik/"
        },
        {
          "files": [ "../bindings/python/mapnik/printing.py" ],
          "destination": "<(PRODUCT_DIR)/lib/python<(python_version)/mapnik/"
        }
      ],
      "include_dirs": [
        "<@(python_includes)"
      ],
      "msvs_settings": {
        "VCLinkerTool": {
          "AdditionalLibraryDirectories": [
            "<@(python_libs)"
          ]
        }
      },
      "xcode_settings": {
        "WARNING_CFLAGS": [
          "-Wno-missing-field-initializers"
        ],
        "DYLIB_INSTALL_NAME_BASE": "@rpath"
      },
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_thread_lib)",
              "<(boost_system_lib)",
              "<(boost_regex_lib)",
              "<(icuuc_lib)",
              "<(icuin_lib)",
              "<(boost_python_lib)",
              "python<(python_version2).lib"
            ],
            "defines":["HAVE_ROUND","HAVE_HYPOT"]
          },
          {
            "libraries":[
                "-lboost_python-<(python_version)",
                "-lboost_thread",
                "-lboost_system",
            ]
          }
        ],
        [ "OS=='mac'",
          {
            "libraries": [ "-undefined dynamic_lookup" ],
          }
        ]
      ]
    },
    {
      "target_name": "nik2img",
      "type": "executable",
      "product_dir":"bin",
      "sources": [ "<!@(find ../utils/nik2img/ -name '*.cpp')" ],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_program_options_lib)",
              "<(boost_filesystem_lib)",
              "<(boost_system_lib)",
              "<(icuuc_lib)"
            ],
          },
          {
            "libraries":[
              "-lboost_system",
              "-lboost_filesystem",
              "-lboost_program_options"
            ]
          }
        ]
      ]
    },
    {
      "target_name": "shapeindex",
      "type": "executable",
      "product_dir":"bin",
      "sources": [ "<!@(find ../utils/shapeindex/ -name '*.cpp')" ],
      "include_dirs":["../plugins/input/shape/"],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_program_options_lib)",
              "<(boost_system_lib)",
            ],
          },
          {
            "libraries":[
              "-lboost_system",
              "-lboost_program_options"
            ]
          }
        ]
      ]
    },
    {
      "target_name": "geojson",
      "product_prefix":"",
      "type": "loadable_module",
      "product_dir": "lib/mapnik/input",
      "dependencies": [ "mapnik", "mapnik-json" ],
      "product_extension": "input",
      "sources": [ "<!@(find ../plugins/input/geojson/ -name '*.cpp')" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries": [
              "<(icuuc_lib)",
            ]
          }
        ]
      ]
    },
    {
      "target_name": "topojson",
      "product_prefix":"",
      "type": "loadable_module",
      "product_dir": "lib/mapnik/input",
      "dependencies": [ "mapnik", "mapnik-json" ],
      "product_extension": "input",
      "sources": [ "<!@(find ../plugins/input/topojson/ -name '*.cpp')" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries": [
              "<(icuuc_lib)",
            ]
          }
        ]
      ]
    },
    {
      "target_name": "shape",
      "product_prefix":"",
      "type": "loadable_module",
      "product_dir": "lib/mapnik/input",
      "product_extension": "input",
      "sources": [ "<!@(find ../plugins/input/shape/ -name '*.cpp')" ],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(icuuc_lib)"
            ],
          }
        ]
      ]
    },
    {
      "target_name": "csv",
      "product_prefix":"",
      "type": "loadable_module",
      "product_dir": "lib/mapnik/input",
      "product_extension": "input",
      "sources": [ "<!@(find ../plugins/input/csv/ -name '*.cpp')" ],
      "dependencies": [ "mapnik", "mapnik-wkt", "mapnik-json" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_system_lib)",
              "<(icuuc_lib)"
            ],
          }
        ]
      ]
    },
    {
      "target_name": "raster",
      "product_prefix":"",
      "type": "loadable_module",
      "product_dir": "lib/mapnik/input",
      "product_extension": "input",
      "sources": [ "<!@(find ../plugins/input/raster/ -name '*.cpp')" ],
      "dependencies": [ "mapnik" ]
    },
    {
      "target_name": "gdal",
      "product_prefix":"",
      "type": "loadable_module",
      "product_dir": "lib/mapnik/input",
      "product_extension": "input",
      "sources": [ "<!@(find ../plugins/input/gdal/ -name '*.cpp')" ],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries": [
              "gdal_i.lib",
              "libexpat.lib",
              "<(boost_system_lib)",
              "<(icuuc_lib)",
              "odbccp32.lib"
            ]
          } ,
          {
            "libraries": [
              "-lgdal"
            ]
          }
        ]
      ]
    },
    {
      "target_name": "ogr",
      "product_prefix":"",
      "type": "loadable_module",
      "product_dir": "lib/mapnik/input",
      "product_extension": "input",
      "sources": [ "<!@(find ../plugins/input/ogr/ -name '*.cpp')" ],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries": [
              "gdal_i.lib",
              "libexpat.lib",
              "<(boost_system_lib)",
              "<(icuuc_lib)",
              "odbccp32.lib"
            ]
          } ,
          {
            "libraries": [
              "-lgdal"
            ]
          }
        ]
      ]
    },
    # {
    #   "target_name": "python",
    #   "product_prefix":"",
    #   "type": "loadable_module",
    #   "product_dir": "lib/mapnik/input",
    #   "product_extension": "input",
    #   "sources": [ "<!@(find ../plugins/input/python/ -name '*.cpp')" ],
    #   "dependencies": [ "mapnik" ],
    #   "include_dirs": [
    #     "<@(python_includes)"
    #   ],
    #   "msvs_settings": {
    #     "VCLinkerTool": {
    #       "AdditionalLibraryDirectories": [
    #         "<@(python_libs)"
    #       ]
    #     }
    #   },
    #   "conditions": [
    #     ["OS=='win'",
    #       {
    #         "libraries":[
    #           "<(boost_thread_lib)",
    #           "<(boost_system_lib)",
    #           "<(boost_regex_lib)",
    #           "<(icuuc_lib)",
    #           "<(icuin_lib)",
    #           "<(boost_python_lib)",
    #           "python<(python_version2).lib"
    #         ],
    #         "defines":["HAVE_ROUND","HAVE_HYPOT"]
    #       },
    #       {
    #         "libraries":[
    #             "-lboost_python-<(python_version)",
    #             "-lboost_thread",
    #             "-lboost_system",
    #             "-L<@(python_libs)",
    #             "-lpython<(python_version)"
    #         ]
    #       }
    #     ]
    #   ]
    # },
    {
      "target_name": "postgis",
      "product_prefix":"",
      "type": "loadable_module",
      "product_dir": "lib/mapnik/input",
      "product_extension": "input",
      "sources": [ "<!@(find ../plugins/input/postgis/ -name '*.cpp')" ],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries": [
              "<(pq_lib)",
              "wsock32.lib",
              "advapi32.lib",
              "shfolder.lib",
              "secur32.lib",
              "<(icuuc_lib)",
              "ws2_32.lib",
              "<(boost_regex_lib)"
            ]
          } ,
          {
            "libraries": [
              "-lpq",
              "-lpthread",
              "-lboost_regex"
            ]
          }
        ]
      ]
    },
    {
      "target_name": "pgraster",
      "product_prefix":"",
      "type": "loadable_module",
      "product_dir": "lib/mapnik/input",
      "product_extension": "input",
      "sources": [ "<!@(find ../plugins/input/pgraster/ -name '*.cpp')" ],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries": [
              "<(pq_lib)",
              "wsock32.lib",
              "advapi32.lib",
              "shfolder.lib",
              "secur32.lib",
              "<(icuuc_lib)",
              "ws2_32.lib",
            ]
          } ,
          {
            "libraries": [
              "-lpq",
              "-lpthread"
            ]
          }
        ]
      ]
    },
    {
      "target_name": "sqlite",
      "product_prefix":"",
      "type": "loadable_module",
      "product_dir": "lib/mapnik/input",
      "product_extension": "input",
      "sources": [ "<!@(find ../plugins/input/sqlite/ -name '*.cpp')" ],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries": [
              "sqlite3.lib",
              "<(icuuc_lib)",
            ]
          } ,
          {
            "libraries": [ "-lsqlite3"]
          }
        ]
      ]
    },
    {
      "target_name": "agg_blend_src_over_test",
      "type": "executable",
      "product_dir":"test",
      "sources": [ "../tests/cpp_tests/agg_blend_src_over_test.cpp"],
      "dependencies": [ "mapnik" ]
    },
    {
      "target_name": "clipping_test",
      "type": "executable",
      "product_dir":"test",
      "sources": [ "../tests/cpp_tests/clipping_test.cpp"],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_filesystem_lib)",
              "<(boost_system_lib)"
            ],
          } ,
          {
            "libraries": [ "-lboost_system","-lboost_filesystem"]
          }
        ]
      ]
    },
    {
      "target_name": "conversions_test",
      "type": "executable",
      "product_dir":"test",
      "sources": [ "../tests/cpp_tests/conversions_test.cpp"],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(icuuc_lib)"
            ],
          } ,
          {
            "libraries": [ "-lboost_system","-lboost_filesystem"]
          }
        ]
      ]
    },
    {
      "target_name": "exceptions_test",
      "type": "executable",
      "product_dir":"test",
      "sources": [ "../tests/cpp_tests/exceptions_test.cpp"],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_filesystem_lib)",
              "<(boost_system_lib)"
            ],
          } ,
          {
            "libraries": [ "-lboost_system","-lboost_filesystem"]
          }
        ]
      ]
    },
    {
      "target_name": "font_registration_test",
      "type": "executable",
      "product_dir":"test",
      "sources": [ "../tests/cpp_tests/font_registration_test.cpp"],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_filesystem_lib)",
              "<(boost_system_lib)"
            ],
          } ,
          {
            "libraries": [ "-lboost_system","-lboost_filesystem"]
          }
        ]
      ]
    },
    {
      "target_name": "fontset_runtime_test",
      "type": "executable",
      "product_dir":"test",
      "sources": [ "../tests/cpp_tests/fontset_runtime_test.cpp"],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(icuuc_lib)",
              "<(boost_filesystem_lib)",
              "<(boost_system_lib)"
            ],
          } ,
          {
            "libraries": [ "-lboost_system","-lboost_filesystem"]
          }
        ]
      ]
    },
    {
      "target_name": "geometry_converters_test",
      "type": "executable",
      "product_dir":"test",
      "sources": [ "../tests/cpp_tests/geometry_converters_test.cpp"],
      "dependencies": [ "mapnik", "mapnik-wkt" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_filesystem_lib)",
              "<(boost_system_lib)"
            ],
          } ,
          {
            "libraries": [ "-lboost_system","-lboost_filesystem"]
          }
        ]
      ]
    },
    {
      "target_name": "simplify_converters_test",
      "type": "executable",
      "product_dir":"test",
      "sources": [ "../tests/cpp_tests/simplify_converters_test.cpp"],
      "dependencies": [ "mapnik", "mapnik-wkt" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_filesystem_lib)",
              "<(boost_system_lib)"
            ],
          } ,
          {
            "libraries": [ "-lboost_system","-lboost_filesystem"]
          }
        ]
      ]
    },
    {
      "target_name": "image_io_test",
      "type": "executable",
      "product_dir":"test",
      "sources": [ "../tests/cpp_tests/image_io_test.cpp"],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_filesystem_lib)",
              "<(boost_system_lib)"
            ],
          } ,
          {
            "libraries": [ "-lboost_system","-lboost_filesystem"]
          }
        ]
      ]
    },
    {
      "target_name": "label_algo_test",
      "type": "executable",
      "product_dir":"test",
      "sources": [ "../tests/cpp_tests/label_algo_test.cpp"],
      "dependencies": [ "mapnik" ]
    },
    {
      "target_name": "map_request_test",
      "type": "executable",
      "product_dir":"test",
      "sources": [ "../tests/cpp_tests/map_request_test.cpp"],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_system_lib)"
            ],
          } ,
          {
            "libraries": [ "-lboost_system","-lboost_filesystem"]
          }
        ]
      ]
    },
    {
      "target_name": "params_test",
      "type": "executable",
      "product_dir":"test",
      "sources": [ "../tests/cpp_tests/params_test.cpp"],
      "dependencies": [ "mapnik" ]
    },
    {
      "target_name": "wkb_formats_test",
      "type": "executable",
      "product_dir":"test",
      "sources": [ "../tests/cpp_tests/wkb_formats_test.cpp"],
      "dependencies": [ "mapnik" ]
    },
    {
      "target_name": "test_rendering",
      "type": "executable",
      "sources": [ "../benchmark/test_rendering.cpp" ],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_system_lib)"
            ]
          }
        ]
      ]
    }
  ]
}
