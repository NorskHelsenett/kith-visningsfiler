<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epj2="http://www.kith.no/xmlstds/epj/epj2/2008-02-20" xmlns:m1="http://www.kith.no/xmlstds/epj/meta/2008-02-20" exclude-result-prefixes="epj2">
	
	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
	
	<xsl:template match="epj2:GenereltJournalnotat">
	<xsl:if test="not(preceding-sibling::epj2:GenereltJournalnotat)">
		<br/>
	</xsl:if>
		<!--<div class="epj2:GenereltJournalnotat">-->
			<xsl:apply-templates/>
		<!--</div>-->
	</xsl:template>
	<xsl:template match="epj2:Journaltekst">
	<table width="100%" border="0" cellspacing="2" cellpadding="2">
		<tr>
		<!--<div class="epj2:Journaltekst">-->
			<xsl:choose>
				<xsl:when test="epj2:Overskriftskode">
					<!--*** Sjekker om kodeverk 9143 "Type viktig medisinsk opplysning" er brukt, da skrives dette ut som viktige opplysninger sammen med CAVE etc. ***-->
					<td width="20%" valign="top">
					<xsl:if test="epj2:Overskriftskode/@S='2.16.578.1.12.4.1.1.9143'">
						<b>Kritisk informasjon</b>
					</xsl:if>
					<xsl:if test="not(epj2:Overskriftskode/@S='2.16.578.1.12.4.1.1.9143')">
						<b>
							<xsl:value-of select="epj2:Overskriftskode/@DN"/>
						</b>
					</xsl:if>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td width="20%" valign="top">
					<xsl:choose>
						<xsl:when test="../../epj2:GenereltJournalnotat/@m1:informasjonskategori='Cave/allergier'">
							<b>Kritisk informasjon</b>	
						</xsl:when>
						<xsl:otherwise>
							<b>Journalnotat</b>
						</xsl:otherwise>
					</xsl:choose>
					</td>	
				</xsl:otherwise>
			</xsl:choose>
			<!--<xsl:if test="epj2:Overskriftskode">
				<h3>
					<xsl:value-of select="epj2:Overskriftskode/@DN"/>
				</h3>
			</xsl:if>-->
			<!--<xsl:value-of select="epj2:Notat"/>-->
			<!--*** Sjekker om kodeverk 9143 "Type viktig medisinsk opplysning" er brukt, da skrives dette ut som viktige opplysninger sammen med CAVE etc. ***-->
			<xsl:if test="epj2:Overskriftskode/@S='2.16.578.1.12.4.1.1.9143'">
				<!--<table id="tableWidth50">
					<tr>-->
						<td width="20%" valign="top">
							<xsl:value-of select="epj2:Overskriftskode/@DN"/>
						</td>
					<!--</tr>
					<tr>-->
						<td width="80%" valign="top">
							<xsl:choose>
								<xsl:when test="count(epj2:Notat/*) &lt; 1">
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="epj2:Notat"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="epj2:Notat"/>
								</xsl:otherwise>
							</xsl:choose>
							<!--<br/>-->
							<xsl:if test="epj2:Merknad">
								<i>&#160;Merknad:</i>&#160;<xsl:value-of select="epj2:Merknad"/>
								<br/>
							</xsl:if>
						</td>
					<!--</tr>
				</table>-->
			</xsl:if>
			<xsl:if test="not(epj2:Overskriftskode/@S='2.16.578.1.12.4.1.1.9143')">
				<!--<table width="95%">
					<tr>-->
						<td width="80%" valign="top">
							<xsl:choose>
								<xsl:when test="count(epj2:Notat/*) &lt; 1">
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="epj2:Notat"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="epj2:Notat"/>
								</xsl:otherwise>
							</xsl:choose>
							<br/>
							<xsl:if test="epj2:Merknad">
								<i>Merknad:</i>&#160;<xsl:value-of select="epj2:Merknad"/>
								<br/>
							</xsl:if>
						</td>
					<!--</tr>
				</table>-->
			</xsl:if>
		<!--</div>-->
		</tr></table>
	</xsl:template>

</xsl:stylesheet>
