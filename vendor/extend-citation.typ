/// Taken from: https://github.com/typst/typst/issues/1139#issuecomment-3299540932
#let title_only_italic_csl = ```xml
<style xmlns="http://purl.org/net/xbiblio/csl" version="1.0" class="in-text">
  <info>
    <title>Title only (italic, optional supplement)</title>
    <id>urn:typst:title-only-italic</id>
  </info>

  <macro name="the-title">
    <text variable="title" font-style="italic"/>
  </macro>

  <!-- (Year[, supplement]) if either exists -->
  <macro name="supp">
    <choose>
      <if variable="issued locator" match="any">
        <group prefix="(" suffix=")">
          <group delimiter=", ">
            <text variable="locator"/>
          </group>
        </group>
      </if>
    </choose>
  </macro>

  <citation>
    <layout>
      <group delimiter=" ">
        <text macro="the-title"/>
        <text macro="supp"/>
      </group>
    </layout>
  </citation>

  <bibliography>
    <layout>
      <group delimiter=" ">
        <text macro="the-title"/>
        <text macro="supp"/>
      </group>
    </layout>
  </bibliography>
</style>
```.text

#let cite_t(key, ..args) = cite(key, style: bytes(title_only_italic_csl), ..args) // *The Book Title*

#let author_only_csl = ```xml
<style xmlns="http://purl.org/net/xbiblio/csl" version="1.0" class="in-text">
  <info><title>Author only</title><id>urn:typst:author-only</id></info>

  <macro name="the-author">
    <choose>
      <if variable="author">
        <names variable="author" and="text" delimiter=", ">
          <name form="short"/>
        </names>
      </if>
    </choose>
  </macro>

  <!-- (supplement) only if provided -->
  <macro name="supp-parens">
    <choose>
      <if variable="locator">
        <group prefix="(" suffix=")"><text variable="locator"/></group>
      </if>
    </choose>
  </macro>

  <citation>
    <layout>
      <group delimiter=" ">
        <text macro="the-author"/>
        <text macro="supp-parens"/>
      </group>
    </layout>
  </citation>

  <bibliography>
    <layout>
      <group delimiter=" ">
        <text macro="the-author"/>
        <text macro="supp-parens"/>
      </group>
    </layout>
  </bibliography>
</style>
```.text

#let cite_a(key, ..args) = cite(key, style: bytes(author_only_csl), ..args) // Smith

#let author_year_csl = ```xml
<style xmlns="http://purl.org/net/xbiblio/csl" version="1.0" class="in-text">
  <info><title>Author (Year[, supplement])</title><id>urn:typst:author-year</id></info>

  <macro name="the-author">
    <choose>
      <if variable="author">
        <names variable="author" and="text" delimiter=", ">
          <name form="long"/>
        </names>
      </if>
    </choose>
  </macro>

  <macro name="year-and-supp">
    <choose>
      <if variable="issued locator" match="any">
        <group prefix="(" suffix=")">
          <group delimiter=", ">
            <date variable="issued"><date-part name="year"/></date>
            <text variable="locator"/>
          </group>
        </group>
      </if>
    </choose>
  </macro>

  <citation>
    <layout>
      <group delimiter=" ">
        <text macro="the-author"/>
        <text macro="year-and-supp"/>
      </group>
    </layout>
  </citation>

  <bibliography>
    <layout>
      <text macro="the-author"/>
    </layout>
  </bibliography>
</style>
```.text

#let cite_ay(key, ..args) = cite(key, style: bytes(author_year_csl), ..args) // Smith (2000)

#let author_pos_csl = ```xml
<style xmlns="http://purl.org/net/xbiblio/csl" version="1.0" class="in-text">
  <info><title>Author’s</title><id>urn:typst:author-pos</id></info>

  <macro name="author-pos">
    <choose>
      <if variable="author">
        <names variable="author" and="text" delimiter=", " suffix="’s">
          <name form="long"/>
        </names>
      </if>
    </choose>
  </macro>

  <macro name="supp-parens">
    <choose>
      <if variable="locator">
        <group prefix="(" suffix=")"><text variable="locator"/></group>
      </if>
    </choose>
  </macro>

  <citation>
    <layout>
      <group delimiter=" ">
        <text macro="author-pos"/>
        <text macro="supp-parens"/>
      </group>
    </layout>
  </citation>

  <bibliography>
    <layout>
      <group delimiter=" ">
        <text macro="author-pos"/>
        <text macro="supp-parens"/>
      </group>
    </layout>
  </bibliography>
</style>
```.text

#let cite_ap(key, ..args) = cite(key, style: bytes(author_pos_csl), ..args) // Smith’s

#let author_pos_year_csl = ```xml
<style xmlns="http://purl.org/net/xbiblio/csl" version="1.0" class="in-text">
  <info><title>Author’s (Year[, supplement])</title><id>urn:typst:author-pos-year</id></info>

  <macro name="author-pos">
    <choose>
      <if variable="author">
        <names variable="author" and="text" delimiter=", " suffix="’s">
          <name form="long"/>
        </names>
      </if>
    </choose>
  </macro>

  <macro name="year-and-supp">
    <choose>
      <if variable="issued locator" match="any">
        <group prefix="(" suffix=")">
          <group delimiter=", ">
            <date variable="issued"><date-part name="year"/></date>
            <text variable="locator"/>
          </group>
        </group>
      </if>
    </choose>
  </macro>

  <citation>
    <layout>
      <group delimiter=" ">
        <text macro="author-pos"/>
        <text macro="year-and-supp"/>
      </group>
    </layout>
  </citation>

  <bibliography>
    <layout>
      <text macro="author-pos"/>
    </layout>
  </bibliography>
</style>
```.text

#let cite_ayp(key, ..args) = cite(key, style: bytes(author_pos_year_csl), ..args) // Smith’s (2000)

#let author_title_year_csl = ```xml
<style xmlns="http://purl.org/net/xbiblio/csl" version="1.0" class="in-text">
  <info>
    <title>Author’s *Title* (Year[, supplement])</title>
    <id>urn:typst:author-title-year-italic</id>
  </info>

  <macro name="author-pos">
    <choose>
      <if variable="author">
        <names variable="author" and="text" delimiter=", " suffix="’s">
          <name form="long"/>
        </names>
      </if>
    </choose>
  </macro>

  <macro name="the-title">
    <text variable="title" font-style="italic"/>
  </macro>

  <macro name="year-and-supp">
    <choose>
      <if variable="issued locator" match="any">
        <group prefix="(" suffix=")">
          <group delimiter=", ">
            <date variable="issued"><date-part name="year"/></date>
            <text variable="locator"/>
          </group>
        </group>
      </if>
    </choose>
  </macro>

  <citation>
    <layout>
      <group delimiter=" ">
        <text macro="author-pos"/>
        <text macro="the-title"/>
        <text macro="year-and-supp"/>
      </group>
    </layout>
  </citation>

  <bibliography>
    <layout>
      <group delimiter=" ">
        <text macro="author-pos"/>
        <text macro="the-title"/>
        <text macro="year-and-supp"/>
      </group>
    </layout>
  </bibliography>
</style>
```.text

#let cite_atyp(key, ..args) = cite(key, style: bytes(author_title_year_csl), ..args) // Smith’s _the great title_ (2000)

