#let title_note_italic_csl = ```xml
<style xmlns="http://purl.org/net/xbiblio/csl" version="1.0" class="in-text">
  <info>
    <title>Title only (italic, optional note in parens)</title>
    <id>urn:typst:title-note-italic</id>
  </info>

  <macro name="the-title">
    <text variable="title" font-style="italic"/>
  </macro>

  <!-- (note) if it exists -->
  <macro name="description">
    <choose>
      <if variable="note" match="any">
        <text variable="note"/>
      </if>
    </choose>
  </macro>

  <citation>
    <layout>
      <group delimiter=" ">
        <text macro="the-title"/>
        <text macro="description"/>
      </group>
    </layout>
  </citation>

  <bibliography>
    <layout>
      <group delimiter=" ">
        <text macro="the-title"/>
        <text macro="description"/>
      </group>
    </layout>
  </bibliography>
</style>
```.text

#let cite_software(key, ..args) = cite(key, style: bytes(title_note_italic_csl), ..args) // *Some Software*: <a note describing it>
