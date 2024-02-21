# version 0.1
# next work: deal with git method


#[
      {
    "name": "nimcorpora",
    "url": "https://github.com/neroist/nimcorpora",
    "method": "git",
    "tags": ["corpora"],
    "description": "A Nim interface for Darius Kazemi's Corpora Project",
    "license": "0BSD",
    "web": "https://github.com/neroist/nimcorpora",
    "doc": "https://neroist.github.io/nimcorpora/nimcorpora.html"
  },
]#
import httpclient, strutils, json
import parsecfg
import std/os 

proc get_config(): tuple =
  # get proxy from config file
  echo os.getAppDir()
  let cfg_file = os.getAppDir() & "\\cfg.ini"
  let cfg = loadConfig(cfg_file)
  let proxy = cfg.getSectionValue("", "proxy")
  let save_as = cfg.getSectionValue("", "save_as")
  return (proxy, save_as)

proc new_packages_info() =
  let client = newHttpClient()
  let response = client.getContent("https://nim-lang.org/nimble/packages.json")
  let  (proxy, save_as) = get_config()
  echo "get proxy: " & proxy
  var data = newJArray()
  for item in parseJson(response):
      # echo item["name"]
      try:
        let url = getStr(item["url"])
        if contains(url, "https://github.com/"):
          # echo "hint: " & getStr(item["url"])
          item["url"] = %(proxy & getStr(item["url"]))
      except KeyError:
          echo "no url"
      finally:  
        add(data, item)

  writeFile(save_as, pretty(data))


new_packages_info()
