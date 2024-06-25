<?xml version="1.0" encoding="utf-8"?>
<!-- Made with XMLSpy v2014 rel.2 sp1 (x64) (http://www.altova.com) by Jan Sigurd Dragsjø (nhn.no) -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="xml" encoding="utf-8"/>
	
	<xsl:template match="/">
		<xsl:result-document href="C:\Users\jand\Documents\_sarepta\standarder\visningsfil\felleskomponenter\kodeverk.xsl" method="text">
			<xsl:call-template name="genererTopp"/>
			<xsl:call-template name="genererDummies"/>
			<!-- Lister alle kodeverk plassert på angitt plassering -->
			<xsl:for-each select="fn:collection('C:\Users\jand\Documents\_visning\kodeverk\*.xml')">
				<xsl:for-each select="document(fn:document-uri(.))//appinfo">
					<xsl:call-template name="genererKodeverk"/>
				</xsl:for-each>
			</xsl:for-each>
			<xsl:call-template name="genererBunn"/>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template name="genererTopp">
		<xsl:text>&lt;?xml version="1.0" encoding="utf-8"?&gt;&#xA;</xsl:text>
		<xsl:text>&lt;!-- Dato oppdatert: </xsl:text><xsl:value-of select="fn:current-dateTime()"/>
		<xsl:text>--&gt;&#xA;</xsl:text>
		<xsl:text>&lt;xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&lt;xsl:output method="html" encoding="utf-8"/&gt;&#xA;</xsl:text>
	</xsl:template>
	
	<xsl:template name="genererDummies">
		<!-- Dummy kodeverk til bruk ved ukjent kodeverk. Viser DN først, deretter OT, deretter {ukjent kode} -->
		<xsl:text>&#9;&lt;xsl:template name="k-dummy"&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&lt;xsl:choose&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&#9;&lt;xsl:when test="@DN"&gt;&lt;xsl:value-of select="@DN"/&gt;&lt;/xsl:when&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&#9;&lt;xsl:when test="@OT"&gt;&lt;xsl:value-of select="@OT"/&gt;&lt;/xsl:when&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&#9;&lt;xsl:otherwise&gt;{ukjent kode}&lt;/xsl:otherwise&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&lt;/xsl:choose&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&lt;/xsl:template&gt;&#xA;</xsl:text>
		<!-- Dummy kodeverk for visning av OT først, deretter V og ev. DN, deretter DN. Kodeverk som benytter denne: 8212 -->
		<xsl:text>&#9;&lt;xsl:template name="k-dummy-OT"&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&lt;xsl:choose&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&#9;&lt;xsl:when test="@OT"&gt;&lt;xsl:value-of select="@OT"/&gt;&lt;/xsl:when&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&#9;&lt;xsl:when test="@V"&gt;&lt;xsl:value-of select="@V"/&gt;&lt;xsl:if test="@DN"&gt;:&#160;&lt;xsl:value-of select="@DN"/&gt;&lt;/xsl:if&gt;&lt;/xsl:when&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&#9;&lt;xsl:when test="@DN"&gt;&lt;xsl:value-of select="@DN"/&gt;&lt;/xsl:when&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&lt;/xsl:choose&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&lt;/xsl:template&gt;&#xA;</xsl:text>
		<!-- Dummy kodeverk for visning av V og ev. DN, deretter DN deretter OT. Kodeverk som benytter denne: 7010 -->
		<xsl:text>&#9;&lt;xsl:template name="k-dummy-V"&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&lt;xsl:choose&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&#9;&lt;xsl:when test="@V"&gt;&lt;xsl:value-of select="@V"/&gt;&lt;xsl:if test="@DN"&gt;:&#160;&lt;xsl:value-of select="@DN"/&gt;&lt;/xsl:if&gt;&lt;/xsl:when&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&#9;&lt;xsl:when test="@DN"&gt;&lt;xsl:value-of select="@DN"/&gt;&lt;/xsl:when&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&#9;&lt;xsl:when test="@OT"&gt;&lt;xsl:value-of select="@OT"/&gt;&lt;/xsl:when&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&lt;/xsl:choose&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&lt;/xsl:template&gt;&#xA;</xsl:text>
	</xsl:template>
	
	<xsl:template name="genererKodeverk">
		<xsl:text>&#9;&lt;xsl:template name="k-</xsl:text>
		<xsl:for-each select="codingScheme[@OID]">
			<xsl:value-of select="@OID"/>
		</xsl:for-each>
		<xsl:text>"&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&lt;xsl:choose&gt;&#xA;</xsl:text>
		<xsl:for-each select="code">
			<xsl:text>&#9;&#9;&#9;&lt;xsl:when test="@V='</xsl:text>
			<xsl:value-of select="@value"/>
			<xsl:text>'"&gt;</xsl:text>
			<xsl:value-of select="@text"/>
			<xsl:text>&lt;/xsl:when&gt;&#xA;</xsl:text>
		</xsl:for-each>
		<xsl:text>&#9;&#9;&#9;&lt;xsl:otherwise&gt;&lt;xsl:call-template name="k-dummy"/&gt;&lt;/xsl:otherwise&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&#9;&lt;/xsl:choose&gt;&#xA;</xsl:text>
		<xsl:text>&#9;&lt;/xsl:template&gt;&#xA;</xsl:text>
	</xsl:template>
	
	<xsl:template name="genererBunn">
		<xsl:text>&lt;/xsl:stylesheet&gt;</xsl:text>
	</xsl:template>
	
</xsl:stylesheet>
