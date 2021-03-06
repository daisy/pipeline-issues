<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns="http://www.w3.org/ns/SMIL"
                exclude-result-prefixes="#all">

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xsl"/>

    <xsl:param name="mo-dir" select="''"/>

    <xsl:variable name="content-doc-rel" select="pf:relativize-uri(base-uri(/*),$mo-dir)"/>

    <xsl:output indent="yes"/>

    <xsl:key name="audio-clips" match="d:clip" use="@idref"/>

    <xsl:template match="/*">
        <smil version="3.0">
            <!--TODO declare non-standard @epub:type vocabularies-->
            <xsl:apply-templates/>
        </smil>
    </xsl:template>

    <xsl:template match="html:body" priority="2">
        <!-- If the body element does have an @id, it is assumed to not link to any audio clip. -->
        <body>
            <xsl:if test="@id">
                <xsl:attribute name="epub:textref" select="concat($content-doc-rel,'#',@id)"/>
            </xsl:if>
            <xsl:copy-of select="@epub:type"/>
            <xsl:apply-templates/>
        </body>
    </xsl:template>

    <xsl:template match="html:*[@id]" priority="1">
        <xsl:variable name="clip" select="key('audio-clips',@id,collection()[/d:audio-clips])"/>
        <xsl:choose>
            <xsl:when test="exists($clip)">
                <par>
                    <xsl:copy-of select="@epub:type"/>
                    <text src="{concat($content-doc-rel,'#',@id)}"/>
                    <audio src="{pf:relativize-uri($clip/resolve-uri(@src,pf:base-uri(.)),$mo-dir)}">
                        <xsl:copy-of select="$clip/(@clipBegin|@clipEnd)"/>
                    </audio>
                </par>
            </xsl:when>
            <xsl:otherwise>
                <seq epub:textref="{concat($content-doc-rel,'#',@id)}">
                    <xsl:copy-of select="@epub:type"/>
                    <xsl:apply-templates/>
                </seq>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="text()"/>

</xsl:stylesheet>
