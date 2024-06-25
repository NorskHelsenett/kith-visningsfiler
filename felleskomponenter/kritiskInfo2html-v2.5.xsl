<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2013 rel.2  sp.2 (http://www.altova.com) by Jan Sigurd Dragsjø - avd. Standardisering, Helsedirektoratet-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:ki="http://www.kith.no/xmlstds/eresept/ki/2013-04-25" 
	exclude-result-prefixes="ki">

<!-- Visningsfil for kritisk info
Inngår i Hdirs visningsfiler versjon 1

29-08-2013: versjon for eResept v2.5
-->
<!-- Endringslogg:
	-	04.06.21: Lagt til xsl:output for å definere at output formatet skal være html
	-	21.10.14: Endret visning av Atc-kode slik at kon V-attributtet vises -->

	<!-- Denne må importeres i hovefila:
	<xsl:import href="funksjoner.xsl"/>
	-->

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<xsl:template match="ki:Allergi">
		<xsl:if test="ki:Legemiddelreaksjon or ki:Reaksjon or ki:Kilde or ki:Oppdatert or ki:Avkreftet or ki:Kommentar">
			<tr>
				<xsl:if test="ki:Legemiddelreaksjon">
					<td width="20%">
						<xsl:for-each select="ki:Legemiddelreaksjon">
							<xsl:if test="ki:Varenavn">
								<div>
									<span class="strong">Varenavn:</span>&#160;
									<xsl:value-of select="ki:Varenavn"/>
								</div>
							</xsl:if>
							<xsl:for-each select="ki:Atc">
								<div>
									<span class="strong">Atc:</span>&#160;<xsl:value-of select="@V"/>
								</div>
							</xsl:for-each>
							<xsl:if test="ki:Hjelpestoffreaksjon">
								<div>
									<span class="strong">Hjelpestoffreaksjon:</span>&#160;
									<xsl:choose>
										<xsl:when test="ki:Hjelpestoffreaksjon='true'">Ja</xsl:when>
										<xsl:otherwise>Nei</xsl:otherwise>
									</xsl:choose>
								</div>
							</xsl:if>
							<xsl:if test="ki:Virkestoff">
								<div>
									<span class="strong">Virkestoff:</span>&#160;
									<xsl:for-each select="ki:Virkestoff">
										<xsl:value-of select="."/>
										<xsl:choose>
											<xsl:when test="position()=last()"></xsl:when>
											<xsl:otherwise>,&#160;</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</div>
							</xsl:if>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="ki:Reaksjon or ki:Kilde">
					<td width="20%">
						<xsl:for-each select="ki:Reaksjon">
							<div>
								<span class="strong">Reaksjon:</span>&#160;
								<xsl:choose>
									<xsl:when test="@DN">
										<xsl:value-of select="@DN"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="k-7497"/>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</xsl:for-each>
						<xsl:for-each select="ki:Kilde">
							<div>
								<span class="strong">Kilde:</span>&#160;
								<xsl:choose>
									<xsl:when test="@DN">
										<xsl:value-of select="@DN"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="k-7498"/>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="ki:Oppdatert or ki:Avkreftet or ki:Kommentar">
					<td>
						<xsl:if test="ki:Oppdatert">
							<div>
								<span class="strong">Oppdatert:</span>&#160;
								<xsl:call-template name="skrivUtDateTime">
									<xsl:with-param name="oppgittTid" select="ki:Oppdatert"/>
								</xsl:call-template>
							</div>
						</xsl:if>
						<xsl:if test="ki:Avkreftet">
							<div>
								<span class="strong">Avkreftet:</span>&#160;
								<xsl:choose>
									<xsl:when test="ki:Avkreftet='true'">Ja</xsl:when>
									<xsl:otherwise>Nei</xsl:otherwise>
								</xsl:choose>
							</div>
						</xsl:if>
						<xsl:if test="ki:Kommentar">
							<div>
								<span class="strong">Kommentar:</span>&#160;
								<xsl:value-of select="ki:Kommentar"/>
							</div>
						</xsl:if>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="k-7497">
		<xsl:choose>
			<xsl:when test="@V='1'">Anafylaksi</xsl:when>
			<xsl:when test="@V='101'">Anafylaktisk&#160;reaksjon</xsl:when>
			<xsl:when test="@V='2'">Reaksjoner&#160;fra sirkulasjonssystemet</xsl:when>
			<xsl:when test="@V='201'">Blodtrykksfall</xsl:when>
			<xsl:when test="@V='202'">Alvorlig&#160;arytmi</xsl:when>
			<xsl:when test="@V='3'">Reaksjon&#160;fra åndedrettsapparatet</xsl:when>
			<xsl:when test="@V='301'">Larynxødem</xsl:when>
			<xsl:when test="@V='302'">Astma</xsl:when>
			<xsl:when test="@V='303'">Uspesifisert&#160;tung&#160;pust</xsl:when>
			<xsl:when test="@V='4'">Reaksjon&#160;fra&#160;CNS</xsl:when>
			<xsl:when test="@V='401'">Alvorlig&#160;påvirket bevissthetsgrad/forvirring&#160;m.m.</xsl:when>
			<xsl:when test="@V='402'">Generaliserte&#160;kramper</xsl:when>
			<xsl:when test="@V='5'">Reaksjon&#160;fra&#160;hud/slimhinner</xsl:when>
			<xsl:when test="@V='501'">Angioødem/Alvorlig generalisert&#160;urticaria</xsl:when>
			<xsl:when test="@V='502'">Andre&#160;alvorlige&#160;hudreaksjoner som&#160;Stevens–Johnson&#160;syndrom</xsl:when>
			<xsl:when test="@V='503'">Epidermiolyse, alvorlige&#160;bulløse&#160;reaksjoner, vaskulitter m.m.</xsl:when>
			<xsl:when test="@V='504'">Mindre&#160;alvorlig&#160;hudreaksjon som&#160;kløe/hevelse/begrenset&#160;urticaria/erytem</xsl:when>
			<xsl:when test="@V='505'">Irritasjon&#160;i&#160;øyne,&#160;nese,&#160;hals</xsl:when>
			<xsl:when test="@V='6'">Reaksjon&#160;fra&#160;GI-traktus</xsl:when>
			<xsl:when test="@V='601'">Oppkast/diaré/mavesmerter</xsl:when>
			<xsl:when test="@V='7'">Andre&#160;reaksjoner</xsl:when>
			<xsl:when test="@V='701'">Leversvikt/redusert&#160;leverfunksjon</xsl:when>
			<xsl:when test="@V='702'">Nyresvikt/redusert&#160;nyrefunksjon</xsl:when>
			<xsl:when test="@V='703'">Blod:&#160;aplasier/dysplasier</xsl:when>
			<xsl:when test="@V='704'">Rhabdomyolyse</xsl:when>
			<xsl:when test="@V='705'">Annen&#160;alvorlig&#160;reaksjon</xsl:when>
			<xsl:when test="@V='706'">Annen&#160;mindre&#160;alvorlig&#160;reaksjon</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="k-7498">
		<xsl:choose>
			<xsl:when test="@V='1'">Resultat&#160;av&#160;tester/analyser</xsl:when>
			<xsl:when test="@V='2'">Observert&#160;av&#160;behandlende&#160;lege</xsl:when>
			<xsl:when test="@V='3'">Pasientens&#160;egne&#160;opplysninger</xsl:when>
			<xsl:when test="@V='4'">Pårørendes&#160;opplysninger</xsl:when>
			<xsl:when test="@V='5'">Hentet&#160;fra&#160;tidligere&#160;journal</xsl:when>
			<xsl:when test="@V='6'">Annet</xsl:when>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
