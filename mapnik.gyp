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
      "WIN32_LEAN_AND_MEAN",
      "BIGINT",
      "BOOST_REGEX_HAS_ICU",
      "HAVE_JPEG",
      "MAPNIK_USE_PROJ4",
      "MAPNIK_NO_ATEXIT",
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
      "../", # boost shim
      "<@(includes)/",
      "<@(includes)/gdal",
      "<@(includes)/freetype2",
      "<@(includes)/cairo"
    ],
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
          "common_defines": [
            "MAPNIK_HAS_DLCFN",
            "MAPNIK_MEMORY_MAPPED_FILE",
            "U_CHARSET_IS_UTF8=1"
          ],
          "common_libraries": [
            "-L<@(libs)"
          ]
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
        '<!@(python glob-files.py "../src/wkt/*.cpp")' #search pattern must be within double quotes ("")
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
        '<!@(python glob-files.py "../src/json/*.cpp")' #search pattern must be within double quotes ("")
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
        '<!@(python glob-files.py "../deps/agg/src/*.cpp")', #search pattern must be within double quotes ("")
        '<!@(python glob-files.py "../src/agg/*.cpp")',
        '<!@(python glob-files.py "../src/cairo/*.cpp")',
        '<!@(python glob-files.py "../src/grid/*.cpp")',
        '<!@(python glob-files.py "../src/group/*.cpp")',
        '<!@(python glob-files.py "../src/renderer_common/*.cpp")',
        '<!@(python glob-files.py "../src/svg/*.cpp")',
        '<!@(python glob-files.py "../src/svg/*/*.cpp")',
        '<!@(python glob-files.py "../src/text/*.cpp")',
        '<!@(python glob-files.py "../src/text/*/*.cpp")',
        '<!@(python glob-files.py "../src/util/*.cpp")',
        '<!@(python glob-files.py "../src/*.cpp")'
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
              "ws2_32.lib",
              "jpeg.lib",
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
          },
        }
      }
    },
    {
      "target_name": "mapnik-render",
      "type": "executable",
      "product_dir":"bin",
      "sources": [
        '<!@(python glob-files.py "../utils/mapnik-render/*.cpp")' #search pattern must be within double quotes ("")
      ],
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
      "sources": [ '<!@(python glob-files.py "../utils/shapeindex/*.cpp")' ],
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
      "target_name": "mapnik-index",
      "type": "executable",
      "product_dir":"bin",
      "dependencies": [ "mapnik", "mapnik-wkt", "mapnik-json" ],
      "sources": [ '<!@(python glob-files.py "../utils/mapnik-index/*.cpp")' ],
      "include_dirs":[
        "<@(common_includes)"
      ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_program_options_lib)",
              "<(boost_system_lib)",
              "<(icuuc_lib)"
            ],
          },
          {
            "libraries":[
              "-lboost_system",
              "-lboost_program_options",
              "-licuuc"
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
      "sources": [ '<!@(python glob-files.py "../plugins/input/geojson/*.cpp")' ],
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
      "sources": [ '<!@(python glob-files.py "../plugins/input/topojson/*.cpp")' ],
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
      "sources": [ '<!@(python glob-files.py "../plugins/input/shape/*.cpp")' ],
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
      "sources": [ '<!@(python glob-files.py "../plugins/input/csv/*.cpp")' ],
      "dependencies": [ "mapnik", "mapnik-wkt", "mapnik-json" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_system_lib)",
              "<(icuuc_lib)",
              "harfbuzz.lib"
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
      "sources": [ '<!@(python glob-files.py "../plugins/input/raster/*.cpp")' ],
      "dependencies": [ "mapnik" ]
    },
    {
      "target_name": "gdal",
      "product_prefix":"",
      "type": "loadable_module",
      "product_dir": "lib/mapnik/input",
      "product_extension": "input",
      "sources": [ '<!@(python glob-files.py "../plugins/input/gdal/*.cpp")' ],
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
              "-lgdal",
              "-lproj",
              "-lexpat",
              "-lz",
              "-ljpeg",
              "-ltiff"
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
      "sources": [ '<!@(python glob-files.py "../plugins/input/ogr/*.cpp")' ],
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
              "-lgdal",
              "-lproj",
              "-lexpat",
              "-lz",
              "-ljpeg",
              "-ltiff"
            ]
          }
        ]
      ]
    },
    {
      "target_name": "postgis",
      "product_prefix":"",
      "type": "loadable_module",
      "product_dir": "lib/mapnik/input",
      "product_extension": "input",
      "sources": [ '<!@(python glob-files.py "../plugins/input/postgis/*.cpp")' ],
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
      "sources": [ '<!@(python glob-files.py "../plugins/input/pgraster/*.cpp")' ],
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
      "sources": [ '<!@(python glob-files.py "../plugins/input/sqlite/*.cpp")' ],
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
      "target_name": "test",
      "type": "executable",
      "product_dir":"test",
      "sources": [
        '<!@(python glob-files.py "../test/unit/*.cpp")',
        '<!@(python glob-files.py "../test/unit/*/*.cpp")'
      ],
      "include_dirs":[
        "../test"
      ],
      "dependencies": [ "mapnik", "mapnik-json", "mapnik-wkt" ],
      "conditions": [
        ["OS=='win'",
          {
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
              "ws2_32.lib",
              "jpeg.lib",
              "freetype.lib",
              "zlib.lib",
              "cairo.lib",
              "harfbuzz.lib"
            ],
          },
          {
            "libraries": [ "-lboost_system", "-lboost_filesystem", "-licuuc"]
          }
        ]
      ]
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
    },
    {
      "target_name": "test_proj_transform1",
      "type": "executable",
      "sources": [ "../benchmark/test_proj_transform1.cpp" ],
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
    },
    {
      "target_name": "test_quad_tree",
      "type": "executable",
      "sources": [ "../benchmark/test_quad_tree.cpp" ],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_system_lib)",
              "<(icuuc_lib)",
              "cairo.lib",
              "proj.lib",
            ]
          }
        ]
      ]
    },
    {
      "target_name": "test_expression_parse",
      "type": "executable",
      "sources": [ "../benchmark/test_expression_parse.cpp" ],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_system_lib)",
            ]
          }
        ]
      ]
    },
    {
      "target_name": "test_face_ptr_creation",
      "type": "executable",
      "sources": [ "../benchmark/test_face_ptr_creation.cpp" ],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_system_lib)",
            ]
          }
        ]
      ]
    },
    {
      "target_name": "test_font_registration",
      "type": "executable",
      "sources": [ "../benchmark/test_font_registration.cpp" ],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_system_lib)",
              "<(icuuc_lib)",
              "cairo.lib",
              "proj.lib",
            ]
          }
        ]
      ]
    },
    {
      "target_name": "test_offset_converter",
      "type": "executable",
      "sources": [ "../benchmark/test_offset_converter.cpp" ],
      "dependencies": [ "mapnik" ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_system_lib)",
            ]
          }
        ]
      ]
    },
    {
      "target_name": "test_visual_run",
      "dependencies": [ "mapnik" ],
      "type": "executable",
      "sources": [
        "../test/visual/report.cpp",
        "../test/visual/runner.cpp",
        "../test/visual/run.cpp"
      ],
      "include_dirs":[
        "../test"
      ],
      "conditions": [
        ["OS=='win'",
          {
            "libraries":[
              "<(boost_system_lib)",
              "<(icuuc_lib)",
              "cairo.lib",
              "proj.lib",
            ]
          },
          {
            "libraries": [ "-lboost_system","-lboost_filesystem","-lboost_program_options"]
          }
        ]
      ]
    }
  ],
  "conditions": [
    ["OS=='win'", {
      "targets": [
        {
          "target_name": "_mapnik",
          "product_prefix":"",
          "product_dir":"lib/python<(python_version)/mapnik/",
          "type": "loadable_module",
          "product_extension": "<(python_module_extension)",
          "sources": [ '<!@(python glob-files.py "../bindings/python/*/*.cpp")' ],
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


        }
      ]}
    ]
  ]
}
