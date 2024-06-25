<?xml version="1.0" encoding="UTF-8"?>
	<!-- Endringslogg
	- 04.06.21: Lagt til xsl:output for å definere at output formatet skal være html
	- 08.04.21: Endre <span> til <div>, siden block-elementer (<ul>) inni inline-elementer (<span>) kan gi feil visning.
	- 04.12.15: Innføring av felles kodeverksfil. Småjusteringer på layout.
	-->
	<!-- Om
	- Inngår i Hdirs visningsfiler versjon 2.0
	- Laget i XMLSpy v2016 (http://www.altova.com) av Jan Sigurd Dragsjø (nhn.no)
	-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Filer som må importeres. Vanligvis gjøres dette i hovedfila som importerer denne komponentfila. Derfor er de kommentert ut.
	<xsl:import href="funksjoner.xsl"/> 
	<xsl:import href="kodeverk.xsl"/> -->

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Variabel for standard antall kolonner i tabellene-->
	<xsl:variable name="std-col" select="8"/>
	<xsl:variable name="std-td" select="100"/>
	
	
	<!-- Visning av innhold i Notater -->
	<xsl:template name="Notater">
		<xsl:for-each select="child::*[local-name()='GenereltJournalnotat']">	<!-- maxOccurs="unbounded" -->
			<xsl:call-template name="GenereltJournalnotat">
				<xsl:with-param name="stripedCss">
					<xsl:choose>
						<xsl:when test="boolean(position() mod 2)"></xsl:when>
						<xsl:otherwise>striped</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Generelt journalnotat -->
	<xsl:template name="GenereltJournalnotat">
		<xsl:param name="stripedCss" />
		<xsl:for-each select="child::*[local-name()='Journaltekst']">			<!-- maxOccurs="unbounded" -->
			<div class="eh-row-4">
				<xsl:call-template name="Journaltekst">
					<xsl:with-param name="inline" select="false()"/>
					<xsl:with-param name="stripedCss" select="$stripedCss"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Journaltekst -->
	<xsl:template name="Journaltekst">
		<xsl:param name="inline"/>
		<xsl:param name="stripedCss"/>

		<xsl:variable name="classCssLast">
			<xsl:choose>
				<xsl:when test="child::*[local-name()='Merknad'] or not(boolean($inline))"></xsl:when>
				<xsl:otherwise>eh-last-child</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="noteColSpan">
			<xsl:choose>
				<xsl:when test="boolean($inline)">1</xsl:when>
				<xsl:otherwise>2</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="eh-col-{$noteColSpan} {$stripedCss} {$classCssLast}">
			<div class="eh-label">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='Overskriftskode']">
						<xsl:for-each select="child::*[local-name()='Overskriftskode']">
							<xsl:choose>
								<xsl:when test="contains(@S, '9141')"><xsl:call-template name="k-9141"/>&#160;</xsl:when>
								<xsl:when test="contains(@S, '9142')"><xsl:call-template name="k-9142"/>&#160;</xsl:when>
								<xsl:otherwise><xsl:call-template name="k-dummy"/>&#160;</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Notat</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="eh-field">
				<xsl:call-template name="line-breaks">
					<xsl:with-param name="text" select="child::*[local-name()='Notat']"/>
				</xsl:call-template><br/>
			</div>
		</div>

		<xsl:if test="child::*[local-name()='Merknad']">
			<div class="eh-col-1 eh-last-child {$stripedCss}">
				<div class="eh-label">Merknad</div>
				<div class="eh-field">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
					</xsl:call-template><br/>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
