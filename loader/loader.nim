import os, parsecfg, streams

let cfg_file = joinPath(getCurrentDir(), "cfg.ini") 

# var cfg = loadConfig(cfg_file)
# var basedir = cfg.getSectionValue("","base_dir")
# var path = cfg.getSectionValue("","path")
# var other = cfg.getSectionValue("","other_init")
# var path_list = getEnv("path")
# path_list = path & ";" & path_list
# # echo path_list
# putEnv("BASE_DIR", absolutePath(basedir))
# putEnv("PATH", path_list)
# var start_cmd = cfg.getSectionValue("","start_cmd")


var f = newFileStream(cfg_file, fmRead)
var
    start_cmd, other, paused: string

var section = ""
if f != nil:
    var p: CfgParser
    open(p, f, cfg_file)
    while true:
        var e = next(p)
        case e.kind
        of cfgEof: break
        of cfgSectionStart:   ## a ``[section]`` has been parsed
            # echo("new section: " & e.section)
            section = e.section
        of cfgKeyValuePair:
            echo("key-value-pair: " & e.key & ": " & e.value)
            if section == "":
                if e.key == "base_dir":
                    var basedir = e.value
                    putEnv("BASE_DIR", absolutePath(basedir))
                elif e.key == "path":
                    var path_list = getEnv("path")
                    path_list = e.value & ";" & path_list
                    putEnv("PATH", path_list)
                elif e.key == "other_init":
                    other = e.value
                elif e.key == "start_cmd":
                    start_cmd = e.value
                elif e.key == "pause":
                    paused = e.value
            elif section == "env":
                putEnv(e.key, e.value)
        of cfgOption:
            echo("command: " & e.key & ": " & e.value)
        of cfgError:
            echo(e.msg)
        close(p)
else:
    echo("cannot open: " & cfg_file)

putEnv("PYTHONUTF8","1")
discard execShellCmd(other)
echo "运行命令："
echo start_cmd
# echo getEnv("path")
discard execShellCmd(start_cmd)
if paused == "1":
    discard execShellCmd("pause")
