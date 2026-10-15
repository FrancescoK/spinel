require "rexml/document"

# The shape of a Syncthing config.xml (synthetic ids and key): what a client
# reads (the GUI address, API key and tls flag) and the hardening it
# writes back.
XML = <<~XML
  <configuration version="37">
      <folder id="default" label="Default Folder" path="/home/user/Sync" type="sendreceive" rescanIntervalS="3600" fsWatcherEnabled="true">
          <filesystemType>basic</filesystemType>
          <device id="AAAAAAA-BBBBBBB-CCCCCCC-DDDDDDD-EEEEEEE-FFFFFFF-GGGGGGG-HHHHHHH" introducedBy="">
              <encryptionPassword></encryptionPassword>
          </device>
          <minDiskFree unit="%">1</minDiskFree>
      </folder>
      <device id="AAAAAAA-BBBBBBB-CCCCCCC-DDDDDDD-EEEEEEE-FFFFFFF-GGGGGGG-HHHHHHH" name="laptop &amp; co" compression="metadata" introducer="false">
          <address>dynamic</address>
          <paused>false</paused>
      </device>
      <gui enabled="true" tls="false" debugging="false">
          <address>127.0.0.1:8384</address>
          <apikey>abcDEF123-test_key</apikey>
          <theme>default</theme>
      </gui>
      <!-- options follow -->
      <options>
          <listenAddress>default</listenAddress>
          <globalAnnounceEnabled>true</globalAnnounceEnabled>
          <relaysEnabled>true</relaysEnabled>
          <urAccepted>0</urAccepted>
      </options>
  </configuration>
XML

doc = REXML::Document.new(XML)
gui = doc.root.elements["gui"]
p gui.elements["apikey"]&.text
p gui.elements["address"]&.text
p gui.attribute("tls")&.value == "true"
p gui.attribute("missing")
p doc.root.elements["device"].attributes["name"]
p doc.root.elements["folder/device"].attributes["id"][0, 7]

opts = doc.root.elements["options"] || doc.root.add_element("options")
{
  "globalAnnounceEnabled" => "false",
  "localAnnounceEnabled" => "true",
  "relaysEnabled" => "false",
  "natEnabled" => "false",
  "urAccepted" => "-1",
  "crashReportingEnabled" => "false"
}.each { |k, v| (opts.elements[k] || opts.add_element(k)).text = v }
gui = doc.root.elements["gui"] || doc.root.add_element("gui")
(gui.elements["address"] || gui.add_element("address")).text = "127.0.0.1:8384"
puts doc.to_s

fresh = REXML::Document.new("<configuration/>")
fresh.root.add_element("gui").add_element("address").text = "127.0.0.1:8384"
puts fresh.to_s
