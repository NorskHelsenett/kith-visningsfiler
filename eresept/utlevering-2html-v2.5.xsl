<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2013 rel.2  sp.2 (http://www.altova.com) by Jan Sigurd Dragsjø - avd. Standardisering, Helsedirektoratet-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:ul="http://www.kith.no/xmlstds/eresept/utlevering/2013-10-08"  
	xmlns:m1v2.4="http://www.kith.no/xmlstds/eresept/m1/2010-05-01" 
	xmlns:m1v2.5="http://www.kith.no/xmlstds/eresept/m1/2013-10-08" 
	exclude-result-prefixes="mh fk1 ul m1v2.4 m1v2.5">


<!-- Visningsfil for Utlevering -->
<!-- Endringslogg
	- 04.06.21 - La til xsl:output for å definere at output formatet skal være html
	- 04.11.13 - La til visning av Batchnr og endret namespace til ul og m1v2.5 -->

	<xsl:import href="m1-2html-v2.5.xsl"/>
	<xsl:import href="m1-2html-v2.4.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
	
	<xsl:template match="ul:Utlevering">
		<h1>Utlevering&#160;&#160;-&#160;
			<xsl:call-template name="skrivUtDate">
				<xsl:with-param name="oppgittTid" select="ul:Utleveringsdato"/>
			</xsl:call-template>
		</h1>
		<table>
			<tbody>
				<xsl:if test="m1v2.5:ReseptDokLegemiddel">
					<xsl:apply-templates select="m1v2.5:ReseptDokLegemiddel"/>
				</xsl:if>
				<xsl:if test="m1v2.5:ReseptDokHandelsvare">
					<xsl:apply-templates select="m1v2.5:ReseptDokHandelsvare"/>
				</xsl:if>
				<xsl:if test="m1v2.4:ReseptDokLegemiddel">
					<xsl:apply-templates select="m1v2.4:ReseptDokLegemiddel"/>
				</xsl:if>
				<xsl:if test="m1v2.4:ReseptDokHandelsvare">
					<xsl:apply-templates select="m1v2.4:ReseptDokHandelsvare"/>
				</xsl:if>
				<xsl:if test="ul:Batchnr or ul:Annullering or ul:Avsluttet or ul:ByttereservasjonKunde">
					<tr>
						<xsl:if test="ul:Batchnr">
							<th width="25%">Batchnummer&#160;på&#160;pakning</th>
						</xsl:if>
						<xsl:if test="ul:Annullering">
							<th width="25%">Annullert</th>
						</xsl:if>
						<xsl:if test="ul:Avsluttet">
							<th width="25%">Avsluttet</th>
						</xsl:if>
						<xsl:if test="ul:ByttereservasjonKunde">
							<th width="25%">Byttereservasjon</th>
						</xsl:if>
					</tr>
					<tr>
						<xsl:if test="ul:Batchnr">
							<td width="25%">
								<xsl:value-of select="ul:Batchnr"/>
							</td>
						</xsl:if>
						<xsl:if test="ul:Annullering">
							<td width="25%">
								<xsl:choose>
									<xsl:when test="ul:Annullering='true'">Ja</xsl:when>
									<xsl:otherwise>Nei</xsl:otherwise>
								</xsl:choose>
							</td>
						</xsl:if>
						<xsl:if test="ul:Avsluttet">
							<td width="25%">
								<xsl:choose>
									<xsl:when test="ul:Avsluttet/@V='1'">Ja</xsl:when>
									<xsl:otherwise>Nei</xsl:otherwise>
								</xsl:choose>
							</td>
						</xsl:if>
						<xsl:if test="ul:ByttereservasjonKunde">
							<td width="25%">
								<xsl:choose>
									<xsl:when test="ul:ByttereservasjonKunde='true'">Ja</xsl:when>
									<xsl:otherwise>Nei</xsl:otherwise>
								</xsl:choose>
							</td>
						</xsl:if>
					</tr>
				</xsl:if>
			</tbody>
		</table>
		<xsl:apply-templates select="ul:Intervensjon"/>
		<xsl:apply-templates select="ul:Utleverer"/>
	</xsl:template>
	
	<xsl:template match="ul:Intervensjon">
		<h2>Intervensjon</h2>
		<table>
			<tbody>
				<xsl:if test="ul:Kode or ul:EndringsType">
					<tr>
						<xsl:if test="ul:Kode">
							<th width="25%">Intervensjonskode</th>
						</xsl:if>
						<xsl:if test="ul:EndringsType">
							<th width="25%">Endringstype</th>
						</xsl:if>
					</tr>
					<tr>
						<xsl:if test="ul:Kode">
							<td width="25%">
								<xsl:choose>
									<xsl:when test="ul:Kode/@OT"><xsl:value-of select="ul:Kode/@OT"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="ul:Kode/@DN"/></xsl:otherwise>
								</xsl:choose>
							</td>
						</xsl:if>
						<xsl:if test="ul:EndringsType">
							<td width="25%">
								<xsl:choose>
									<xsl:when test="ul:EndringsType/@DN"><xsl:value-of select="ul:EndringsType/@DN"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="ul:EndringsType/@V"/></xsl:otherwise>
								</xsl:choose>
							</td>
						</xsl:if>
					</tr>
				</xsl:if>
				<xsl:if test="ul:KonfKunde or ul:KonfLege or ul:Begrunnelse">
					<tr>
						<xsl:if test="ul:KonfKunde">
							<th width="25%">Konferert med kunde</th>
						</xsl:if>
						<xsl:if test="ul:KonfLege">
							<th width="25%">Legens Id (<xsl:value-of select="ul:KonfLege/fk1:TypeId/@V"/>)</th>
						</xsl:if>
						<xsl:if test="ul:Begrunnelse">
							<th width="25%">Begrunnelse</th>
						</xsl:if>
					</tr>
					<tr>
						<xsl:if test="ul:KonfKunde">
							<td width="25%">
								<xsl:choose>
									<xsl:when test="ul:KonfKunde='true'">Ja</xsl:when>
									<xsl:otherwise>Nei</xsl:otherwise>
								</xsl:choose>
							</td>
						</xsl:if>
						<xsl:if test="ul:KonfLege">
							<td width="25%">
								<xsl:value-of select="ul:KonfLege/fk1:Id"/>
							</td>
						</xsl:if>
						<xsl:if test="ul:Begrunnelse">
							<td width="25%">
								<xsl:value-of select="ul:Begrunnelse"/>
							</td>
						</xsl:if>
					</tr>
				</xsl:if>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="ul:Utleverer">
		<h2>Utleverer</h2>
		<table>
			<tbody>
				<xsl:if test="ul:HerId or ul:Navn">
					<tr>
						<xsl:if test="ul:HerId">
							<th width="25%">HER-id (<xsl:value-of select="ul:HerId/fk1:TypeId/@V"/>)</th>
						</xsl:if>
						<xsl:if test="ul:Navn">
							<th width="25%">Organisasjonsnavn</th>
						</xsl:if>
					</tr>
					<tr>
						<xsl:if test="ul:HerId">
							<td width="25%"><xsl:value-of select="ul:HerId/fk1:Id"/></td>
						</xsl:if>
						<xsl:if test="ul:Navn">
							<td width="25%"><xsl:value-of select="ul:Navn"/></td>
						</xsl:if>
					</tr>
				</xsl:if>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="ul:RekvirentPapir">
		<h2>Rekvirent papirresept</h2>
		<table>
			<tbody>
				<xsl:if test="ul:Ident or ul:Fornavn or ul:Etternavn or ul:Spesialitet">
					<tr>
						<xsl:if test="ul:Ident">
							<th width="25%">HPR-nr</th>
						</xsl:if>
						<xsl:if test="ul:Fornavn or ul:Etternavn">
							<th width="25%">Navn</th>
						</xsl:if>
						<xsl:if test="ul:Spesialitet">
							<th width="25%">Spesialitet</th>
						</xsl:if>
					</tr>
					<tr>
						<xsl:if test="ul:Ident">
							<td width="25%"><xsl:value-of select="ul:Ident/fk1:Id"/></td>
						</xsl:if>
						<xsl:if test="ul:Fornavn or ul:Etternavn">
							<td width="25%">
								<xsl:if test="ul:Etternavn"><xsl:value-of select="ul:Etternavn"/>,&#160;</xsl:if>
								<xsl:if test="ul:Fornavn"><xsl:value-of select="ul:Fornavn"/></xsl:if>
							</td>
						</xsl:if>
						<xsl:if test="ul:Spesialitet">
							<td width="25%">
							<xsl:choose>
								<xsl:when test="ul:Spesialitet/@OT"><xsl:value-of select="ul:Spesialitet/@OT"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="ul:Spesialitet/@DN"/></xsl:otherwise>
							</xsl:choose>
							</td>
						</xsl:if>
					</tr>
				</xsl:if>
				<xsl:if test="ul:Inst or ul:Dept or ul:RekvirentNordisk or ul:InstitusjonsID">
					<tr>
						<xsl:if test="ul:Inst">
							<th width="25%">Institusjon</th>
						</xsl:if>
						<xsl:if test="ul:Dept">
							<th width="25%">Avdeling</th>
						</xsl:if>
						<xsl:if test="ul:RekvirentNordisk">
							<th width="25%">Nordisk/eøs</th>
						</xsl:if>
						<xsl:if test="ul:InstitusjonsID">
							<th width="25%">InstitusjonsID</th>
						</xsl:if>
					</tr>
					<tr>
						<xsl:if test="ul:Inst">
							<td width="25%"><xsl:value-of select="ul:Inst"/></td>
						</xsl:if>
						<xsl:if test="ul:Dept">
							<td width="25%"><xsl:value-of select="ul:Dept"/></td>
						</xsl:if>
						<xsl:if test="ul:RekvirentNordisk">
							<td width="25%">
								<xsl:choose>
									<xsl:when test="ul:RekvirentNordisk='true'">Ja</xsl:when>
									<xsl:otherwise>Nei</xsl:otherwise>
								</xsl:choose>
							</td>
						</xsl:if>
						<xsl:if test="ul:InstitusjonsID">
							<td width="25%">
							<xsl:choose>
								<xsl:when test="ul:InstitusjonsID/@OT"><xsl:value-of select="ul:InstitusjonsID/@OT"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="ul:InstitusjonsID/@DN"/></xsl:otherwise>
							</xsl:choose>
							</td>
						</xsl:if>
					</tr>
				</xsl:if>
			</tbody>
		</table>
	</xsl:template>
	
</xsl:stylesheet>
