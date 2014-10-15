{
  'includes': [
    './common.gypi'
  ],
  'variables': {
    'includes%':'',
    'libs%':'',
    'configuration%':'',
    'platform%':'',
    'common_defines': [
      'BIGINT',
      'BOOST_REGEX_HAS_ICU',
      'HAVE_JPEG',
      'MAPNIK_USE_PROJ4',
      'HAVE_PNG',
      'HAVE_TIFF',
      'HAVE_WEBP',
      'MAPNIK_THREADSAFE',
      'HAVE_CAIRO',
      'GRID_RENDERER',
      'SVG_RENDERER',
      'BOOST_SPIRIT_USE_PHOENIX_V3=1'
    ],
    'common_includes': [
      '../include', # mapnik
      '../deps/', # mapnik/sparsehash
      '../deps/agg/include/', # agg
      '../deps/clipper/include/', # clipper
      '../', # boost shim
      '<@(includes)/',
      '<@(includes)/gdal',
      '<@(includes)/freetype2',
      '<@(includes)/libxml2',
      '<@(includes)/cairo'
    ],
    'python_root': '<!(python -c "import sys,ntpath,posixpath;print(sys.prefix).replace(ntpath.sep,posixpath.sep)")',
    "conditions": [
      ["OS=='win'", {
          'common_defines': [
             'LIBXML_STATIC', # static libxml: libxml2_a.lib
             'BOOST_VARIANT_DO_NOT_USE_VARIADIC_TEMPLATES',
             'BOOST_LIB_TOOLSET="vc140"',
             'BOOST_COMPILER="14.0"',
             '_WINDOWS'
          ],
          'common_libraries': [],
          'python_includes':'<(python_root)/include',
          'python_libs':'<(python_root)/libs'
      }, {
          'common_defines': ['SHAPE_MEMORY_MAPPED_FILE','U_CHARSET_IS_UTF8=1'],
          'common_libraries': [
            '-L<@(libs)'
          ],
          'python_includes':'/usr/include/python2.7',
          'python_libs':'/usr/lib/python2.7'
      }],
      ["OS=='mac'", {
          'common_libraries': [
            '-Wl,-search_paths_first'
          ]
      }],
      ["OS=='linux'", {
          'common_libraries': [
            '-pthread',
            '-ldl',
            '-lrt'
          ]
      }]
    ]
  },
  'targets': [
    {
      'target_name': 'mapnik_wkt',
      'type': 'static_library',
      'sources': [
        '<!@(find ../src/wkt/ -name "*.cpp")'
      ],
      'defines': [
        '<@(common_defines)'
      ],
      'include_dirs':[
          '<@(common_includes)'
      ]
    },
    {
      'target_name': 'mapnik_json',
      'type': 'static_library',
      'sources': [
        '<!@(find ../src/json/ -name "*.cpp")'
      ],
      'defines': [
        '<@(common_defines)'
      ],
      'include_dirs':[
          '<@(common_includes)'
      ]
    },
    {
      'target_name': 'mapnik',
      'product_name': 'mapnik',
      'type': 'shared_library',
      'sources': [
        '<!@(find ../deps/agg/src/ -name "*.cpp")',
        '<!@(find ../deps/clipper/src/ -name "*.cpp")',
        '<!@(find ../src/agg/ -name "*.cpp")',
        '<!@(find ../src/cairo/ -name "*.cpp")',
        '<!@(find ../src/grid/ -name "*.cpp")',
        '<!@(find ../src/group/ -name "*.cpp")',
        '<!@(find ../src/renderer_common/ -name "*.cpp")',
        '<!@(find ../src/svg/ -name "*.cpp")',
        '<!@(find ../src/text/ -name "*.cpp")',
        '<!@(find ../src/ -name "*.cpp" -maxdepth 1)'
      ],
      'xcode_settings': {
        'SDKROOT': 'macosx',
        'SUPPORTED_PLATFORMS':['macosx'],
        'PUBLIC_HEADERS_FOLDER_PATH': 'include',
        'OTHER_CPLUSPLUSFLAGS':[
          '-ftemplate-depth-300'
        ],
        'DYLIB_INSTALL_NAME_BASE': '@loader_path'
      },
      'msvs_settings': {
        'VCLinkerTool': {
          'AdditionalLibraryDirectories': [
              '<@(libs)/'
          ]
        }
      },
      'defines': [
        '<@(common_defines)'
      ],
      'libraries': [
        '<@(common_libraries)'
      ],
      "conditions": [
        ["OS=='win'", {
           'defines': ['MAPNIK_EXPORTS'],
           'libraries':[
              'libboost_filesystem-vc140-mt-1_56.lib',
              'libboost_regex-vc140-mt-1_56.lib',
              'libboost_system-vc140-mt-1_56.lib',
              'libpng16.lib',
              'proj.lib',
              'libtiff_i.lib',
              'libwebp_dll.lib',
              #'libxml2.lib', #dynamic
              'libxml2_a.lib', #static
              # needed if libxml2 is static
              'ws2_32.lib',
              'libjpeg.lib',
              'icuuc.lib',
              'icuin.lib',
              'freetype.lib',
              'zlib.lib',
              'cairo.lib',
              'harfbuzz.lib'
          ]
        },{
            'libraries':[
              '-lboost_filesystem',
              '-lboost_regex',
              '-lboost_system',
              '-lcairo',
              '-lpixman-1',
              '-lexpat',
              '-lpng',
              '-lproj',
              '-ltiff',
              '-lwebp',
              '-lxml2',
              '-licui18n',
              '-ljpeg',
              '-licuuc',
              '-lfreetype',
              '-licudata',
              '-lharfbuzz',
              '-lz'
            ]
          }
        ]
      ],
      'include_dirs':[
          '<@(common_includes)'
      ],
      'direct_dependent_settings': {
        'include_dirs': [
          '<@(common_includes)'
        ],
        'defines': [
          '<@(common_defines)'
        ],
        'libraries':[
          '<@(common_libraries)'
        ],
        'msvs_settings': {
          'VCLinkerTool': {
            'AdditionalLibraryDirectories': [
                '<@(libs)/'
            ]
          }
        }
      }
    },
    {
        "target_name": "_mapnik",
        "type": "loadable_module",
        "product_extension": "pyd",
        "sources": [ '<!@(find ../bindings/python/ -name "*.cpp")' ],
        "dependencies": [ "mapnik", 'mapnik_wkt', 'mapnik_json' ],
        'include_dirs': [
          '<@(python_includes)'
        ],
        'msvs_settings': {
          'VCLinkerTool': {
            'AdditionalLibraryDirectories': [
                '<@(python_libs)'
            ]
          }
        },
        "xcode_settings": {
          "WARNING_CFLAGS": [
            "-Wno-missing-field-initializers"
          ],
          'DYLIB_INSTALL_NAME_BASE': '@rpath'
        },
        "conditions": [
          ["OS=='win'", {
             'libraries':[
                'libboost_thread-vc140-mt-1_56.lib',
                'libboost_system-vc140-mt-1_56.lib',
                'libboost_regex-vc140-mt-1_56.lib',
                'icuuc.lib',
                'icuin.lib',
                'python27.lib'
            ],
            'defines':['HAVE_ROUND','HAVE_HYPOT']
          },{
              'libraries':[
                #'-lboost_thread'
              ]
            }
          ],
          [ 'OS=="mac"', {
            'libraries': [ '-undefined dynamic_lookup' ],
          }]
        ]
    },
    {
        "target_name": "nik2img",
        "type": "executable",
        "sources": [ '<!@(find ../utils/nik2img/ -name "*.cpp")' ],
        "dependencies": [ "mapnik" ],
        "conditions": [
          ["OS=='win'", {
             'libraries':[
                'libboost_program_options-vc140-mt-1_56.lib',
                'libboost_filesystem-vc140-mt-1_56.lib',
                'libboost_system-vc140-mt-1_56.lib',
                'icuuc.lib'
            ],
          },{
              'libraries':[
                '-lboost_system',
                '-lboost_filesystem',
                '-lboost_program_options'
              ]
            }
          ]
        ]
    },
    {
        "target_name": "shapeindex",
        "type": "executable",
        "sources": [ '<!@(find ../utils/shapeindex/ -name "*.cpp")' ],
        'include_dirs':['../plugins/input/shape/'],
        "dependencies": [ "mapnik" ],
        "conditions": [
          ["OS=='win'", {
             'libraries':[
                'libboost_program_options-vc140-mt-1_56.lib',
                'libboost_system-vc140-mt-1_56.lib',
            ],
          },{
              'libraries':[
                '-lboost_system',
                '-lboost_program_options'
              ]
            }
          ]
        ]
    },
    {
        "target_name": "shape",
        "type": "loadable_module",
        "product_extension": "input",
        "sources": [ '<!@(find ../plugins/input/shape/ -name "*.cpp")' ],
        "dependencies": [ "mapnik" ],
        "conditions": [
          ["OS=='win'", {
             'libraries':[
                #'libboost_system-vc140-mt-1_56.lib',
               # 'icuuc.lib'
            ],
          }]
        ]
    },
    {
        "target_name": "csv",
        "type": "loadable_module",
        "product_extension": "input",
        "sources": [ '<!@(find ../plugins/input/csv/ -name "*.cpp")' ],
        "dependencies": [ "mapnik", 'mapnik_wkt', 'mapnik_json' ],
        "conditions": [
          ["OS=='win'", {
             'libraries':[
                'libboost_system-vc140-mt-1_56.lib',
                'icuuc.lib'
            ],
          }]
        ]
    },
    {
        "target_name": "raster",
        "type": "loadable_module",
        "product_extension": "input",
        "sources": [ '<!@(find ../plugins/input/raster/ -name "*.cpp")' ],
        "dependencies": [ "mapnik" ]
    },
    {
        "target_name": "gdal",
        "type": "loadable_module",
        "product_extension": "input",
        "sources": [ '<!@(find ../plugins/input/gdal/ -name "*.cpp")' ],
        "dependencies": [ "mapnik" ],
        'conditions': [
          ['OS=="win"', {
            'libraries': [
                'gdal_i.lib',
                'libexpat.lib',
                'libboost_system-vc140-mt-1_56.lib',
                'icuuc.lib',
                'odbccp32.lib'
            ]
          } , {
            'libraries': [
                '-lgdal'
             ]
          }]
       ]
    },
    {
        "target_name": "ogr",
        "type": "loadable_module",
        "product_extension": "input",
        "sources": [ '<!@(find ../plugins/input/ogr/ -name "*.cpp")' ],
        "dependencies": [ "mapnik" ],
        'conditions': [
          ['OS=="win"', {
            'libraries': [
                'gdal_i.lib',
                'libexpat.lib',
                'libboost_system-vc140-mt-1_56.lib',
                'icuuc.lib',
                'odbccp32.lib'
            ]
          } , {
            'libraries': [
                '-lgdal'
             ]
          }]
       ]
    },
    {
        "target_name": "postgis",
        "type": "loadable_module",
        "product_extension": "input",
        "sources": [ '<!@(find ../plugins/input/postgis/ -name "*.cpp")' ],
        "dependencies": [ "mapnik" ],
        'conditions': [
          ['OS=="win"', {
            'libraries': [
                'libpq.lib',
                'wsock32.lib',
                'advapi32.lib',
                'shfolder.lib',
                'secur32.lib',
                'icuuc.lib',
                'ws2_32.lib',
                'libboost_regex-vc140-mt-1_56.lib'
            ]
          } , {
            'libraries': [
                '-lpq',
                '-lpthread',
                '-lboost_regex'
            ]
          }]
        ]
    },
    {
        "target_name": "pgraster",
        "type": "loadable_module",
        "product_extension": "input",
        "sources": [ '<!@(find ../plugins/input/pgraster/ -name "*.cpp")' ],
        "dependencies": [ "mapnik" ],
        'conditions': [
          ['OS=="win"', {
            'libraries': [
                'libpq.lib',
                'wsock32.lib',
                'advapi32.lib',
                'shfolder.lib',
                'secur32.lib',
                'icuuc.lib',
                'ws2_32.lib',
            ]
          } , {
            'libraries': [
                '-lpq',
                '-lpthread'
            ]
          }]
        ]
    },
    {
        "target_name": "sqlite",
        "type": "loadable_module",
        "product_extension": "input",
        "sources": [ '<!@(find ../plugins/input/sqlite/ -name "*.cpp")' ],
        "dependencies": [ "mapnik" ],
        'conditions': [
          ['OS=="win"', {
            'libraries': [
                  'sqlite3.lib',
                  'icuuc.lib',
            ]
          } , {
            'libraries': [ '-lsqlite3']
          }]
        ]
    },
    {
        "target_name": "geojson",
        "type": "loadable_module",
        "dependencies": [ "mapnik", 'mapnik_json' ],
        "product_extension": "input",
        "sources": [ '<!@(find ../plugins/input/geojson/ -name "*.cpp")' ],
        'conditions': [
          ['OS=="win"', {
            'libraries': [
                'icuuc.lib',
            ]
          }]
        ]
    },
    {
        "target_name": "agg_blend_src_over_test",
        "type": "executable",
        "sources": [ "../tests/cpp_tests/agg_blend_src_over_test.cpp"],
        "dependencies": [ "mapnik" ]
    },
    {
        "target_name": "clipping_test",
        "type": "executable",
        "sources": [ "../tests/cpp_tests/clipping_test.cpp"],
        "dependencies": [ "mapnik" ],
         "conditions": [
          ["OS=='win'", {
             'libraries':[
                'libboost_filesystem-vc140-mt-1_56.lib',
               'libboost_system-vc140-mt-1_56'
            ],
          } , {
            'libraries': [ '-lboost_system','-lboost_filesystem']
          }]
        ]
    },
    {
        "target_name": "conversions_test",
        "type": "executable",
        "sources": [ "../tests/cpp_tests/conversions_test.cpp"],
        "dependencies": [ "mapnik" ],
        "conditions": [
          ["OS=='win'", {
             'libraries':[
                'icuuc.lib'
            ],
          } , {
            'libraries': [ '-lboost_system','-lboost_filesystem']
          }]
        ]
    },
    {
        "target_name": "exceptions_test",
        "type": "executable",
        "sources": [ "../tests/cpp_tests/exceptions_test.cpp"],
        "dependencies": [ "mapnik" ],
         "conditions": [
          ["OS=='win'", {
             'libraries':[
                'libboost_filesystem-vc140-mt-1_56.lib',
               'libboost_system-vc140-mt-1_56'
            ],
          } , {
            'libraries': [ '-lboost_system','-lboost_filesystem']
          }]
        ]
    },
    {
        "target_name": "font_registration_test",
        "type": "executable",
        "sources": [ "../tests/cpp_tests/font_registration_test.cpp"],
        "dependencies": [ "mapnik" ],
         "conditions": [
          ["OS=='win'", {
             'libraries':[
                'libboost_filesystem-vc140-mt-1_56.lib',
               'libboost_system-vc140-mt-1_56'
            ],
          } , {
            'libraries': [ '-lboost_system','-lboost_filesystem']
          }]
        ]
    },
    {
        "target_name": "fontset_runtime_test",
        "type": "executable",
        "sources": [ "../tests/cpp_tests/fontset_runtime_test.cpp"],
        "dependencies": [ "mapnik" ],
        "conditions": [
          ["OS=='win'", {
             'libraries':[
                'icuuc.lib',
                'libboost_filesystem-vc140-mt-1_56.lib',
               'libboost_system-vc140-mt-1_56'
            ],
          } , {
            'libraries': [ '-lboost_system','-lboost_filesystem']
          }]
        ]
    },
    {
        "target_name": "geometry_converters_test",
        "type": "executable",
        "sources": [ "../tests/cpp_tests/geometry_converters_test.cpp"],
        "dependencies": [ "mapnik" ],
         "conditions": [
          ["OS=='win'", {
             'libraries':[
                'libboost_filesystem-vc140-mt-1_56.lib',
               'libboost_system-vc140-mt-1_56'
            ],
          } , {
            'libraries': [ '-lboost_system','-lboost_filesystem']
          }]
        ]
    },
    {
        "target_name": "image_io_test",
        "type": "executable",
        "sources": [ "../tests/cpp_tests/image_io_test.cpp"],
        "dependencies": [ "mapnik" ],
         "conditions": [
          ["OS=='win'", {
             'libraries':[
                'libboost_filesystem-vc140-mt-1_56.lib',
               'libboost_system-vc140-mt-1_56'
            ],
          } , {
            'libraries': [ '-lboost_system','-lboost_filesystem']
          }]
        ]
    },
    {
        "target_name": "label_algo_test",
        "type": "executable",
        "sources": [ "../tests/cpp_tests/label_algo_test.cpp"],
        "dependencies": [ "mapnik" ]
    },
    {
        "target_name": "map_request_test",
        "type": "executable",
        "sources": [ "../tests/cpp_tests/map_request_test.cpp"],
        "dependencies": [ "mapnik" ],
         "conditions": [
          ["OS=='win'", {
             'libraries':[
                'libboost_system-vc140-mt-1_56.lib'
            ],
          } , {
            'libraries': [ '-lboost_system','-lboost_filesystem']
          }]
        ]
    },
    {
        "target_name": "params_test",
        "type": "executable",
        "sources": [ "../tests/cpp_tests/params_test.cpp"],
        "dependencies": [ "mapnik" ]
    },
    {
        "target_name": "wkb_formats_test",
        "type": "executable",
        "sources": [ "../tests/cpp_tests/wkb_formats_test.cpp"],
        "dependencies": [ "mapnik" ]
    },
   {
       "target_name": "test_rendering",
       "type": "executable",
       "sources": [ "../benchmark/test_rendering.cpp" ],
       "dependencies": [ "mapnik" ],
       "conditions": [
         ["OS=='win'", {
            'libraries':[
               'libboost_system-vc140-mt-1_56'
           ]
         }]
       ]
   }
  ],
}