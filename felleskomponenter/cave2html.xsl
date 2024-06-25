<?xml version="1.0" encoding="UTF-8"?>
	<!-- Endringslogg
	- 09.08.22: Semantisk HTML (endre <span class="strong"> til <b>)
	- 10.05.22: Fikset AnafylaktiskeReaksjoner
	- 04.06.21: Lagt til xsl:output for å definere at output formatet skal være html
	- 08.04.21: Endre <span> til <div>, siden block-elementer (<ul>) inni inline-elementer (<span>) kan gi feil visning.
	- 04.12.15: Innføring av felles kodeverksfil. Småjusteringer på layout.
	-->
	<!-- Om
	- Inngår i Hdirs visningsfiler versjon 2.0
	- Laget i XMLSpy v2016 (http://www.altova.com) av Jan Sigurd Dragsjø (nhn.no)
	-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Filer som må importeres. Vanligvis gjøres dette i hovedfila som importerer denne komponentfila. Derfor er de kommentert ut. -->
	<xsl:import href="funksjoner.xsl"/> 
	<xsl:import href="kodeverk.xsl"/>
	<xsl:import href="journalnotat2html.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
	
	<!-- Variabel for standard antall kolonner i tabellene-->
	<xsl:variable name="std-col" select="8"/>
	<xsl:variable name="std-td" select="100"/>
	
	<!-- Visning av innhold i Cave -->
	<xsl:template name="Cave">
		<xsl:variable name="antCave">
			<xsl:choose>
				<xsl:when test="count(.//child::*[local-name()='StikkordCave']) = 0">1</xsl:when>
				<xsl:otherwise><xsl:value-of select="count(.//child::*[local-name()='StikkordCave'])"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h4 eh-last-child">Cave</div>
		</div>

		<xsl:for-each select=".//child::*[local-name()='StikkordCave']">
			<xsl:variable name="stripedCss">
				<xsl:choose>
					<xsl:when test="boolean(position() mod 2)"></xsl:when>
					<xsl:otherwise>striped</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<div class="eh-row-4">
				<div class="eh-col-1 {$stripedCss}">
					<div class="eh-label">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='CaveStikkord']"/>
						</xsl:call-template>
					</div>
				</div>
				<xsl:for-each select="child::*[local-name()='Journaltekst']">
					<xsl:call-template name="Journaltekst">
						<xsl:with-param name="inline" select="true()"/>
						<xsl:with-param name="stripedCss" select="$stripedCss"/>
					</xsl:call-template>
				</xsl:for-each>
			</div>
		</xsl:for-each>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-last-child horRuler"><hr /></div>
		</div>

		<xsl:for-each select="child::*[local-name()='Allerginotat']">	<!-- maxOccurs="unbounded" -->
			<xsl:call-template name="Allerginotat">
				<xsl:with-param name="stripedCss">
					<xsl:choose>
						<xsl:when test="boolean(position() mod 2)"></xsl:when>
						<xsl:otherwise>striped</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

	</xsl:template>

	<!-- Visning av innhold i Allerginotat -->
	<xsl:template name="Allerginotat">
		<xsl:param name="stripedCss"/>

		<xsl:variable name="kolonnefyll" select="number(boolean(child::*[local-name()='Allergi']/child::*[local-name()='VirkestoffLegemiddel'] | child::*[local-name()='Allergi']/child::*[local-name()='KodeAnnetStoff']))"/>
		<xsl:variable name="antNotat">
			<xsl:choose>
				<xsl:when test="count(.//child::*[local-name()='Journaltekst']) = 0">1</xsl:when>
				<xsl:otherwise>count(.//child::*[local-name()='Journaltekst'])</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div class="eh-row-4">
			<xsl:for-each select="child::*[local-name()='Allergi']">
				<div class="eh-col-1 {$stripedCss}">
					<div class="eh-label">Allergisk&#160;mot:&#160;<xsl:value-of select="child::*[local-name()='AllergiskMot']"/>&#160;</div>
					<div class="eh-field">
						<xsl:if test="child::*[local-name()='VirkestoffLegemiddel'] or child::*[local-name()='KodeAnnetStoff']">
							<xsl:if test="child::*[local-name()='VirkestoffLegemiddel']">
								<b>ATC:</b>&#160;
								<xsl:for-each select="child::*[local-name()='VirkestoffLegemiddel']">
									<xsl:call-template name="k-dummy"/>&#160;
								</xsl:for-each>&#160;
							</xsl:if>
							<xsl:if test="child::*[local-name()='KodeAnnetStoff']">
								<div>
									<b>Stoff:</b>&#160;
									<xsl:for-each select="child::*[local-name()='KodeAnnetStoff']">
										<xsl:call-template name="k-dummy"/>&#160;
									</xsl:for-each>&#160;
								</div>
							</xsl:if>
						</xsl:if>
					</div>
				</div>
				<div class="eh-col-1 {$stripedCss}">
					<div class="eh-label">Info</div>
					<div class="eh-field">
						<xsl:if test="child::*[local-name()='HensynVedForskrivning']='true' or child::*[local-name()='HensynMatDrikke']='true'">
							Ta&#160;hensyn&#160;<xsl:if test="child::*[local-name()='HensynVedForskrivning']='true'">ved&#160;forskrivning<xsl:if test="child::*[local-name()='HensynMatDrikke']='true'">&#160;og </xsl:if></xsl:if>
							<xsl:if test="child::*[local-name()='HensynMatDrikke']='true'">i&#160;forbindelse&#160;med&#160;mat&#160;og&#160;drikke</xsl:if>
						</xsl:if>
						<xsl:if test="child::*[local-name()='Kontaktallergi']='true' or child::*[local-name()='PollenInnsektstikk']='true'">
							<xsl:if test="child::*[local-name()='HensynVedForskrivning']='true' or child::*[local-name()='HensynMatDrikke']='true'">
								<br/>
							</xsl:if>
							Gjelder&#160;ved&#160;<xsl:if test="child::*[local-name()='Kontaktallergi']='true'">kontakt<xsl:if test="child::*[local-name()='PollenInnsektstikk']='true'">&#160;og </xsl:if></xsl:if>
								<xsl:if test="child::*[local-name()='PollenInnsektstikk']='true'">insektstikk,&#160;pollen&#160;eller&#160;lignende</xsl:if>
						</xsl:if>
						<xsl:if test="child::*[local-name()='AnafylaktiskeReaksjoner']">
							<xsl:if test="child::*[local-name()='HensynVedForskrivning']='true' or child::*[local-name()='HensynMatDrikke']='true' or child::*[local-name()='Kontaktallergi']='true' or child::*[local-name()='PollenInnsektstikk']='true'">
								<br/>
							</xsl:if>
							Har&#160;hatt&#160;anafylaktiske&#160;reaksjoner:&#160;
								<xsl:for-each select="child::*[local-name()='AnafylaktiskeReaksjoner']">
									<xsl:call-template name="k-1103"/>&#160;
								</xsl:for-each>
						</xsl:if>
					</div>
				</div>
			</xsl:for-each>

			<xsl:for-each select="child::*[local-name()='Journaltekst']"> 	<!-- only first node -->
				<xsl:if test="position()=1">
					<xsl:call-template name="Journaltekst">		<!-- inline: max 2 columns -->
						<xsl:with-param name="inline" select="true()"/>
						<xsl:with-param name="stripedCss" select="$stripedCss"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:for-each>
		</div>

		<xsl:for-each select="child::*[local-name()='Journaltekst']">	<!-- maxOccurs="unbounded" -->
			<xsl:if test="position()!=1">
				<div class="eh-row-4">
					<xsl:call-template name="Journaltekst">		<!-- not inline: max 3 columns -->
						<xsl:with-param name="inline" select="false()"/>
						<xsl:with-param name="stripedCss" select="$stripedCss"/>
					</xsl:call-template>
				</div>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
