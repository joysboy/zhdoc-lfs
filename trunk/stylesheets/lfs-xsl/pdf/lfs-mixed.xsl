<?xml version='1.0' encoding='UTF-8'?>

<!--
$LastChangedBy: manuel $
$Date: 2007-07-06 05:18:33 +0800 (五, 06  7月 2007) $
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="1.0">

  <!-- This stylesheet contains misc params, attribute sets and templates
       for output formating.
       This file is for that templates that don't fit in other files. -->

    <!-- What space do you want between normal paragraphs. -->
  <xsl:attribute-set name="normal.para.spacing">
    <xsl:attribute name="space-before.optimum">0.6em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">0.4em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">0.8em</xsl:attribute>
    <xsl:attribute name="orphans">3</xsl:attribute>
    <xsl:attribute name="widows">3</xsl:attribute>
  </xsl:attribute-set>

    <!-- Properties associated with verbatim text. -->
  <xsl:attribute-set name="verbatim.properties">
    <xsl:attribute name="keep-with-previous.within-column">always</xsl:attribute>
    <xsl:attribute name="space-before.optimum">0.6em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">0.4em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">0.8em</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0.6em</xsl:attribute>
    <xsl:attribute name="space-after.minimum">0.4em</xsl:attribute>
    <xsl:attribute name="space-after.maximum">0.8em</xsl:attribute>
    <xsl:attribute name="hyphenate">false</xsl:attribute>
    <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
    <xsl:attribute name="white-space-collapse">false</xsl:attribute>
    <xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
    <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
    <xsl:attribute name="text-align">start</xsl:attribute>
  </xsl:attribute-set>

    <!-- Should verbatim environments be shaded? 1 =yes, 0 = no -->
  <xsl:param name="shade.verbatim" select="1"/>

    <!-- Properties that specify the style of shaded verbatim listings -->
  <xsl:attribute-set name="shade.verbatim.style">
    <xsl:attribute name="background-color">#E9E9E9</xsl:attribute>
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="border-width">0.5pt</xsl:attribute>
    <xsl:attribute name="border-color">#888</xsl:attribute>
    <xsl:attribute name="padding-start">5pt</xsl:attribute>
    <xsl:attribute name="padding-top">2pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">2pt</xsl:attribute>
  </xsl:attribute-set>

    <!-- para:
           Skip empty "Home page" in packages.xml.
           Allow forced line breaks inside paragraphs emulating literallayout.
           Removed vertical space in variablelist. -->
    <!-- The original template is in {docbook-xsl}/fo/block.xsl -->
  <xsl:template match="para">
    <xsl:choose>
      <xsl:when test="child::ulink[@url=' ']"/>
      <xsl:when test="./@remap='verbatim'">
        <fo:block xsl:use-attribute-sets="verbatim.properties">
          <xsl:call-template name="anchor"/>
          <xsl:apply-templates/>
        </fo:block>
      </xsl:when>
      <xsl:when test="ancestor::variablelist">
        <fo:block>
          <xsl:attribute name="space-before.optimum">0.1em</xsl:attribute>
          <xsl:attribute name="space-before.minimum">0em</xsl:attribute>
          <xsl:attribute name="space-before.maximum">0.2em</xsl:attribute>
          <xsl:call-template name="anchor"/>
          <xsl:apply-templates/>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="normal.para.spacing">
          <xsl:call-template name="anchor"/>
          <xsl:apply-templates/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

    <!-- screen, literallayout:
          Self-made template that creates a fo:block wrapper with keep-together
          processing instruction support around the output generated by
          original screen templates. -->
  <xsl:template match="screen|literallayout">
    <xsl:variable name="keep.together">
      <xsl:call-template name="pi.dbfo_keep-together"/>
    </xsl:variable>
    <fo:block>
      <xsl:attribute name="keep-together.within-column">
        <xsl:choose>
          <xsl:when test="$keep.together != ''">
            <xsl:value-of select="$keep.together"/>
          </xsl:when>
          <xsl:otherwise>always</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-imports/>
    </fo:block>
  </xsl:template>

    <!-- literal:
           Be sure that literal will use allways normal font weight. -->
    <!-- The original template is in {docbook-xsl}/fo/inline.xsl -->
  <xsl:template match="literal">
    <fo:inline  font-weight="normal">
      <xsl:call-template name="inline.monoseq"/>
    </fo:inline>
  </xsl:template>

    <!-- inline.monoseq:
           Added hyphenate-url support to classname, exceptionname, interfacename,
           methodname, computeroutput, constant, envar, filename, function, code,
           literal, option, promt, systemitem, varname, sgmltag, tag, and uri -->
    <!-- The original template is in {docbook-xsl}/fo/inline.xsl -->
  <xsl:template name="inline.monoseq">
    <xsl:param name="content">
      <xsl:call-template name="simple.xlink">
        <xsl:with-param name="content">
          <xsl:choose>
            <xsl:when test="ancestor::para and not(ancestor::screen)
                            and not(descendant::ulink)">
              <xsl:call-template name="hyphenate-url">
                <xsl:with-param name="url">
                  <xsl:apply-templates/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:param>
    <fo:inline xsl:use-attribute-sets="monospace.properties">
      <xsl:if test="@dir">
        <xsl:attribute name="direction">
          <xsl:choose>
            <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
            <xsl:otherwise>rtl</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="$content"/>
    </fo:inline>
  </xsl:template>

    <!-- inline.italicmonoseq:
           Added hyphenate-url support to parameter, replaceable, structfield,
           function/parameter, and function/replaceable -->
    <!-- The original template is in {docbook-xsl}/fo/inline.xsl -->
  <xsl:template name="inline.italicmonoseq">
    <xsl:param name="content">
      <xsl:call-template name="simple.xlink">
        <xsl:with-param name="content">
          <xsl:choose>
            <xsl:when test="ancestor::para and not(ancestor::screen)
                            and not(descendant::ulink)">
              <xsl:call-template name="hyphenate-url">
                <xsl:with-param name="url">
                  <xsl:apply-templates/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:param>
    <fo:inline font-style="italic" xsl:use-attribute-sets="monospace.properties">
      <xsl:call-template name="anchor"/>
      <xsl:if test="@dir">
        <xsl:attribute name="direction">
          <xsl:choose>
            <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
            <xsl:otherwise>rtl</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="$content"/>
    </fo:inline>
  </xsl:template>

    <!-- Show external URLs in italic font -->
  <xsl:attribute-set name="xref.properties">
    <xsl:attribute name="font-style">
      <xsl:choose>
        <xsl:when test="self::ulink">italic</xsl:when>
        <xsl:otherwise>inherit</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

   <!-- Center table title. -->
  <xsl:attribute-set name="formal.title.properties">
    <xsl:attribute name="text-align">
      <xsl:choose>
        <xsl:when test="local-name(.) = 'table'">center</xsl:when>
        <xsl:otherwise>left</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

    <!-- table.layout:
           We want all tables centered. Based on a hack posted
           by Ellen Juhlin on docbook-apps mailing list. -->
    <!-- The original template is in {docbook-xsl}/fo/table.xsl -->
  <xsl:template name="table.layout">
    <xsl:param name="table.content" select="NOTANODE"/>
    <fo:table table-layout="fixed" width="100%">
      <fo:table-column column-width ="proportional-column-width(1)"/>
      <fo:table-column>
        <!-- Set center column width equal to table width -->
        <xsl:attribute name="column-width">
          <xsl:call-template name="table.width"/>
        </xsl:attribute>
      </fo:table-column>
      <fo:table-column column-width ="proportional-column-width(1)"/>
      <fo:table-body>
        <fo:table-row>
          <fo:table-cell column-number="2">
            <xsl:copy-of select="$table.content"/>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
    </fo:table>
  </xsl:template>


  <!-- Revision History -->

    <!-- revhistory titlepage:
           Self-made template to add missing support on bookinfo. -->
  <xsl:template match="revhistory" mode="book.titlepage.verso.auto.mode">
    <fo:block space-before.optimum="2em"
              space-before.minimum="1.5em"
              space-before.maximum="2.5em">
      <xsl:apply-templates select="." mode="book.titlepage.verso.mode"/>
    </fo:block>
  </xsl:template>

    <!-- revhitory title properties -->
  <xsl:attribute-set name="revhistory.title.properties">
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

    <!-- revhistory/revision mode titlepage.mode:
           Removed authorinitials | author support placing
           revremark | revdescription instead on that table-cell. -->
    <!-- The original template is in {docbook-xsl}/fo/titlepage.xsl -->
  <xsl:template match="revhistory/revision" mode="titlepage.mode">
    <xsl:variable name="revnumber" select="revnumber"/>
    <xsl:variable name="revdate"   select="date"/>
    <xsl:variable name="revremark" select="revremark|revdescription"/>
    <fo:table-row>
      <fo:table-cell xsl:use-attribute-sets="revhistory.table.cell.properties">
        <fo:block>
          <xsl:if test="$revnumber">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="'Revision'"/>
            </xsl:call-template>
            <xsl:call-template name="gentext.space"/>
            <xsl:apply-templates select="$revnumber[1]" mode="titlepage.mode"/>
          </xsl:if>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="revhistory.table.cell.properties">
        <fo:block>
          <xsl:apply-templates select="$revdate[1]"/>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="revhistory.table.cell.properties">
        <fo:block>
          <xsl:apply-templates select="$revremark[1]"/>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>


  <!-- Dummy sect1 -->

    <!-- sect1:
           Self-made template to skip dummy sect1 pages generation. -->
  <xsl:template match="sect1">
    <xsl:choose>
      <xsl:when test="@role = 'dummy'"/>
      <xsl:otherwise>
        <xsl:apply-imports/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

    <!-- sect1 mode fop1.outline:
           Self-made template to skip dummy sect1 bookmarks generation. -->
  <xsl:template match="sect1" mode="fop1.outline">
    <xsl:choose>
      <xsl:when test="@role = 'dummy'"/>
      <xsl:otherwise>
        <xsl:apply-imports/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

    <!-- toc.line:
           For dummy sect1 output only the title. -->
    <!-- The original template is in {docbook-xsl}/fo/autotoc.xsl -->
  <xsl:template name="toc.line">
    <xsl:param name="toc-context" select="NOTANODE"/>
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="label.markup"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@role = 'dummy'">
        <fo:block text-align="left">
          <xsl:apply-templates select="." mode="titleabbrev.markup"/>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="toc.line.properties">
          <fo:inline keep-with-next.within-line="always">
            <fo:basic-link internal-destination="{$id}">
              <xsl:if test="$label != ''">
                <xsl:copy-of select="$label"/>
                <xsl:value-of select="$autotoc.label.separator"/>
              </xsl:if>
              <xsl:apply-templates select="." mode="titleabbrev.markup"/>
            </fo:basic-link>
          </fo:inline>
          <fo:inline keep-together.within-line="always">
            <xsl:text> </xsl:text>
            <fo:leader leader-pattern="dots"
                       leader-pattern-width="3pt"
                       leader-alignment="reference-area"
                       keep-with-next.within-line="always"/>
            <xsl:text> </xsl:text>
            <fo:basic-link internal-destination="{$id}">
              <fo:page-number-citation ref-id="{$id}"/>
            </fo:basic-link>
          </fo:inline>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
