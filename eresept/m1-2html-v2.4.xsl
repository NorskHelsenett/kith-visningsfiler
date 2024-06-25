<?xml version="1.0" encoding="UTF-8"?>
<!-- Laget i XMLSpy v2013 sp1 (http://www.altova.com) av Jan Sigurd Dragsjø (helsedirektoratet.no) -->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:m1="http://www.kith.no/xmlstds/eresept/m1/2013-10-08" 
	xmlns:m15="http://www.kith.no/xmlstds/eresept/m15/2006-10-06" 
	xmlns:fs="http://www.kith.no/xmlstds/eresept/forskrivning/2013-10-08" 
	exclude-result-prefixes="mh fk1 m1 m15 fs">

<!-- Visningsfil for eReseptmeldingen: M1 med multidose og eventuell vedlegg av M15 -->
<!-- Siste endring:
	- 2022-08-09: v3.2.0: Semantisk HTML
	- 2021-06-04: v3.1.4: La til xsl:output for å definere at output formatet skal være html
	- 2017-09-01: v3.1.3: La in while istedet for if test på om M15 er med.
	- 2017-05-19: v3.1.2: La inn sjekk ved begrunnelse om avslag, bruker da M15:BegrunnelseAvslag i stedet for M1:Begrunnelse
	- 2017-03-27: v3.1.1: Ny parameter for "visningStil". Ny stil "Smooth".
	- 2016-10-25: v3.1.0: La til visningsversjonnr
	- 2014-11-12: Utvidelse for å håndtere flere varienter av faste doserings-dager
	- 2014-04-30: Bugfix av ProdGruppe i handelsvare
	- 2014-03-13: Flyttet plassering av Ref.nr og Refusjonskode. Fikset bug med uendelig rekursjon om Faste ukedager og Faste dager på var begge oppgitt.
	- 2014-01-16: DirektesoknadSlv har fått visning av Ja/Nei istedet for boolsk verdi.
	- 2013-11-01: Mer robust feilmeldingshåndtering.
	- 2013-02-01: Visning av multidose
	- 2011-02-21: Første versjon -->

	<xsl:import href="../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Input-parameter som brukes til å legge ved Søknadssvar fra SLV (m15) -->
	<xsl:param name="vedlegg"/>

	<!-- Variabel for standard antall kolonner i tabellene -->
	<xsl:variable name="std-col" select="8"/>

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m1-2.4 - v3.2.0'"/>
	
	<!-- html oppsett -->
	<xsl:template match="/">
		<html>
			<head>
				<title></title>
				<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/KITH-visning.css')" disable-output-escaping="yes"/>
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/smooth-visning.css')" disable-output-escaping="yes"/>
				</style>
			</head>
			<body>
				<xsl:apply-templates select="mh:MsgHead"/>
			</body>
		</html>
	</xsl:template>

	<!-- Visning av meldingshodet. Tilpasset vinduskonvolutt ved utskrift -->
	<xsl:template match="mh:MsgHead">
		<xsl:call-template name="Topp"/>
		<xsl:call-template name="Innhold"/>
		<xsl:choose>
			<!-- Inngang for å komponere egen bunn i EgetBunnTillegg nedenfor. Foreløpig hoppes den over -->
			<xsl:when test="not(1)">
				<xsl:call-template name="BunnTillegg">
					<xsl:with-param name="stil" select="$stil"/>
					<xsl:with-param name="versjon" select="$versjon"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Bunn">
					<xsl:with-param name="stil" select="$stil"/>
					<xsl:with-param name="versjon" select="$versjon"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Template som kalles fra BunnTillegg i meldingshodet. Kan brukes til visning av egenkomponert bunn -->
	<xsl:template name="EgetBunnTillegg">
	</xsl:template>
	
	<!-- Visning av innhold -->
	<xsl:template name="Innhold" match="m1:Resept">
		<main class="{$stil}">
			<xsl:for-each select="//m1:Resept">
				<h2>Resept
					<xsl:if test="m1:OppdatertFest">
						<font size="2">- Oppdatert FEST:
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="m1:OppdatertFest"/>
							</xsl:call-template>
						</font>
					</xsl:if>
				</h2>
				<table>
					<tbody>
						<xsl:if test="m1:ReseptDokLegemiddel">
							<xsl:apply-templates select="m1:ReseptDokLegemiddel"/>
						</xsl:if>
						<xsl:if test="m1:ReseptDokHandelsvare">
							<xsl:apply-templates select="m1:ReseptDokHandelsvare"/>
						</xsl:if>
						<xsl:if test="m1:Forskrivningsdato or m1:Utloper or //m1:RefKode or //m1:RefHjemmel">
							<tr>
								<xsl:if test="m1:Forskrivningsdato"><th width="25%">Forskrivningsdato</th></xsl:if>
								<xsl:if test="m1:Utloper"><th width="25%">Utløper</th></xsl:if>
								<xsl:if test="//m1:RefKode or //m1:RefHjemmel">
									<th width="25%">
										<xsl:choose>
											<xsl:when test="//m1:RefKode and not(//m1:RefHjemmel)">Refusjonskode</xsl:when>
											<xsl:when test="not(//m1:RefKode) and //m1:RefHjemmel">Ref.hjemmel</xsl:when>
											<xsl:otherwise>Refusjonskode og ref.hjemmel</xsl:otherwise>
										</xsl:choose>
									</th>
								</xsl:if>
							</tr>
							<tr>
								<xsl:if test="m1:Forskrivningsdato">
									<td width="25%">
										<xsl:call-template name="skrivUtTS">
											<xsl:with-param name="oppgittTid" select="m1:Forskrivningsdato"/>
										</xsl:call-template>
									</td>
								</xsl:if>
								<xsl:if test="m1:Utloper">
									<td width="25%">
										<xsl:call-template name="skrivUtTS">
											<xsl:with-param name="oppgittTid" select="m1:Utloper"/>
										</xsl:call-template>
									</td>
								</xsl:if>
								<xsl:if test="//m1:RefKode or //m1:RefHjemmel">
									<td width="25%">
										<xsl:if test="//m1:RefKode">
											<div>
												<xsl:for-each select="//m1:RefKode">
													<xsl:choose>
														<xsl:when test="contains(@S, '7170')">
															<xsl:if test="@V"><xsl:value-of select="@V"/>&#160;(ICPC-2)</xsl:if>
															<xsl:if test="@DN"><xsl:value-of select="@DN"/>&#160;</xsl:if>
															<xsl:if test="@OT"><b>Fritekst:&#160;</b><xsl:value-of select="@OT"/></xsl:if>
														</xsl:when>
														<xsl:when test="contains(@S, '7110')">
															<xsl:if test="@V"><xsl:value-of select="@V"/>&#160;(ICD-10)</xsl:if>
															<xsl:if test="@DN"><xsl:value-of select="@DN"/>&#160;</xsl:if>
															<xsl:if test="@OT"><b>Fritekst:&#160;</b><xsl:value-of select="@OT"/></xsl:if>
														</xsl:when>
														<xsl:when test="contains(@S, '7434')">
															<xsl:choose>
																<xsl:when test="@DN">
																	<xsl:value-of select="@DN"/>
																</xsl:when>
																<xsl:when test="@OT">
																	<span class="strong">Fritekst:&#160;</span><xsl:value-of select="@OT"/>
																</xsl:when>
																<xsl:otherwise>
																	<xsl:for-each select="//m1:RefHjemmel">
																		<xsl:call-template name="k-7434"/>
																	</xsl:for-each>
																</xsl:otherwise>
															</xsl:choose>
														</xsl:when>
														<xsl:when test="contains(@S, '7435')">
															<xsl:choose>
																<xsl:when test="@DN">
																	<xsl:value-of select="@DN"/>
																</xsl:when>
																<xsl:when test="@OT">
																	<span class="strong">Fritekst:&#160;</span><xsl:value-of select="@OT"/>
																</xsl:when>
																<xsl:otherwise>
																	<xsl:for-each select="//m1:RefHjemmel">
																		<xsl:call-template name="k-7435"/>
																	</xsl:for-each>
																</xsl:otherwise>
															</xsl:choose>
														</xsl:when>
														<xsl:otherwise>
															<xsl:choose>
																<xsl:when test="@DN">
																	<xsl:value-of select="@DN"/>
																</xsl:when>
																<xsl:when test="@OT">
																	<span class="strong">Fritekst:&#160;</span><xsl:value-of select="@OT"/>
																</xsl:when>
																<xsl:otherwise>
																	<xsl:value-of select="@V"/>
																</xsl:otherwise>
															</xsl:choose>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:for-each>
											</div>
										</xsl:if>
										<xsl:if test="//m1:RefHjemmel">
											<div>
												<xsl:choose>
													<xsl:when test="//m1:RefHjemmel/@DN">
														<xsl:value-of select="//m1:RefHjemmel/@DN"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:for-each select="//m1:RefHjemmel">
															<xsl:call-template name="k-7427"/>
														</xsl:for-each>
													</xsl:otherwise>
												</xsl:choose>
											</div>
										</xsl:if>
									</td>
								</xsl:if>
							</tr>
						</xsl:if>
						<xsl:if test="//m1:BytteresRekvirent or m1:Vergeinnsynsreservasjon or m1:RekvLegensNavn or m1:RefNr">
							<tr>
								<xsl:if test="//m1:BytteresRekvirent"><th width="25%">Bytteres. rekvirent</th></xsl:if>
								<xsl:if test="m1:Vergeinnsynsreservasjon"><th width="25%">Vergeinnsynsres.</th></xsl:if>
								<xsl:if test="m1:RekvLegensNavn"><th width="25%">Rekv. i legens navn</th></xsl:if>
								<xsl:if test="m1:RefNr"><th width="25%">Ref.nr.</th></xsl:if>
							</tr>
							<tr>
								<xsl:if test="//m1:BytteresRekvirent">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="//m1:BytteresRekvirent/@DN">
												<xsl:value-of select="//m1:BytteresRekvirent/@DN"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:for-each select="//m1:BytteresRekvirent">
													<xsl:call-template name="k-1101"/>
												</xsl:for-each>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:if>
								<xsl:if test="m1:Vergeinnsynsreservasjon">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="m1:Vergeinnsynsreservasjon='true'">Ja</xsl:when>
											<xsl:when test="m1:Vergeinnsynsreservasjon='false'">Nei</xsl:when>
										</xsl:choose>
									</td>
								</xsl:if>
								<xsl:if test="m1:RekvLegensNavn">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="m1:RekvLegensNavn='true'">Ja</xsl:when>
											<xsl:when test="m1:RekvLegensNavn='false'">Nei</xsl:when>
										</xsl:choose>
									</td>
								</xsl:if>
								<xsl:if test="m1:RefNr">
									<td width="25%">
										<xsl:value-of select="m1:RefNr"/>
									</td>
								</xsl:if>
							</tr>
						</xsl:if>
						<xsl:if test="m1:TilEgenPraksis or m1:Frikort or m1:Vernepliktig or m1:SoktIndividRefusjon">
							<tr>
								<xsl:if test="m1:TilEgenPraksis"><th width="25%">Til egen praksis</th></xsl:if>
								<xsl:if test="m1:Frikort"><th width="25%">Frikort</th></xsl:if>
								<xsl:if test="m1:Vernepliktig"><th width="25%">Verneplikt</th></xsl:if>
								<xsl:if test="m1:SoktIndividRefusjon"><th width="25%">Søkt Individrefusjon</th></xsl:if>
							</tr>
							<tr>
								<xsl:if test="m1:TilEgenPraksis">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="m1:TilEgenPraksis='true'">Ja</xsl:when>
											<xsl:when test="m1:TilEgenPraksis='false'">Nei</xsl:when>
										</xsl:choose>
									</td>
								</xsl:if>
								<xsl:if test="m1:Frikort">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="m1:Frikort='true'">Ja</xsl:when>
											<xsl:when test="m1:Frikort='false'">Nei</xsl:when>
										</xsl:choose>
									</td>
								</xsl:if>
								<xsl:if test="m1:Vernepliktig">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="m1:Vernepliktig='true'">Ja</xsl:when>
											<xsl:when test="m1:Vernepliktig='false'">Nei</xsl:when>
										</xsl:choose>
									</td>
								</xsl:if>
								<xsl:if test="m1:SoktIndividRefusjon">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="m1:SoktIndividRefusjon='true'">Ja</xsl:when>
											<xsl:when test="m1:SoktIndividRefusjon='false'">Nei</xsl:when>
										</xsl:choose>
									</td>
								</xsl:if>
							</tr>
						</xsl:if>
					</tbody>
				</table>
				<xsl:if test="//fs:Dosering">
					<xsl:call-template name="fs:Dosering"/>
				</xsl:if>
				<xsl:if test="//m1:LegemiddelUtenMt">
					<xsl:apply-templates select="//m1:LegemiddelUtenMt"/>
				</xsl:if>
				<xsl:if test="m1:Instituert">
					<xsl:apply-templates select="m1:Instituert"/>
				</xsl:if>
				<xsl:if test="m1:EkspAnm">
					<xsl:apply-templates select="m1:EkspAnm"/>
				</xsl:if>
				<xsl:if test="m1:Utlending">
					<xsl:apply-templates select="m1:Utlending"/>
				</xsl:if>
			</xsl:for-each>
		</main>
	</xsl:template>
	
	<xsl:template match="m1:ReseptDokLegemiddel">
		<xsl:choose>
			<xsl:when test=".//fs:Legemiddelblanding">
				<xsl:for-each select=".//fs:Legemiddelblanding">
					<tr>
						<xsl:if test="fs:Navn"><th width="25%">Navn</th></xsl:if>
						<xsl:if test="fs:TilbOppl"><th width="25%">Tilberedning</th></xsl:if>
						<xsl:if test=".//fs:NavnFormStyrke"><th width="25%">NavnFormStyrke</th></xsl:if>
						<xsl:if test=".//fs:Mengde"><th width="25%">Mengde</th></xsl:if>
						<xsl:if test=".//fs:Atc/@V"><th width="25%">Atc</th></xsl:if>
						<xsl:if test=".//fs:Reseptgruppe"><th width="25%">Utlevgr</th></xsl:if>
					</tr>
					<tr>
						<xsl:if test="fs:Navn">
							<td width="25%"><xsl:value-of select="fs:Navn"/></td>
						</xsl:if>
						<xsl:if test="fs:TilbOppl">
							<td width="25%"><xsl:value-of select="fs:TilbOppl"/></td>
						</xsl:if>
						<xsl:if test=".//fs:NavnFormStyrke">
							<td width="25%">
								<xsl:for-each select=".//fs:NavnFormStyrke">
									<xsl:value-of select="."/>&#160;
									<xsl:if test="position()!=last()"><br/></xsl:if>
								</xsl:for-each>
							</td>
						</xsl:if>
						<xsl:if test=".//fs:Mengde">
							<td width="25%">
								<xsl:for-each select=".//fs:Mengde">
									<xsl:value-of select="@V"/><xsl:value-of select="@U"/>&#160;
									<xsl:if test="position()!=last()"><br/></xsl:if>
								</xsl:for-each>
							</td>
						</xsl:if>
						<xsl:if test=".//fs:Atc/@V">
							<td width="25%">
								<xsl:for-each select=".//fs:Atc">
									<xsl:value-of select="@V"/>&#160;
									<xsl:if test="position()!=last()"><br/></xsl:if>
								</xsl:for-each>
							</td>
						</xsl:if>
						<xsl:if test=".//fs:Reseptgruppe">
							<td width="25%">
								<xsl:for-each select=".//fs:Reseptgruppe">
									<xsl:value-of select="@V"/>&#160;
									<xsl:if test="position()!=last()"><br/></xsl:if>
								</xsl:for-each>
							</td>
						</xsl:if>
					</tr>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="//fs:NavnFormStyrke or m1:Mengde or //fs:Mengde or //fs:Virkestoff/fs:Navn or //fs:Atc or //fs:Reseptgruppe">
					<tr>
						<xsl:if test="//fs:NavnFormStyrke"><th width="25%">NavnFormStyrke</th></xsl:if>
						<xsl:if test="m1:Mengde"><th width="25%">Mengde</th></xsl:if>
						<xsl:if test="//fs:Virkestoff/fs:Navn or //fs:Atc/@DN"><th width="25%">Virkestoff</th></xsl:if>
						<xsl:if test="//fs:Atc/@V"><th width="25%">Atc</th></xsl:if>
						<xsl:if test="//fs:Reseptgruppe"><th width="25%">Utlevgr</th></xsl:if>
					</tr>
					<tr>
						<xsl:if test="//fs:NavnFormStyrke"><td width="25%"><xsl:value-of select="//fs:NavnFormStyrke"/></td></xsl:if>
						<xsl:if test="m1:Mengde"><td width="25%"><xsl:value-of select="m1:Mengde/@V"/><xsl:value-of select="m1:Mengde/@U"/></td></xsl:if>
						<xsl:if test="//fs:Virkestoff/fs:Navn or //fs:Atc/@DN">
							<td width="25%">
								<xsl:choose>
									<xsl:when test="//fs:Virkestoff/fs:Navn"><xsl:value-of select="//fs:Virkestoff/fs:Navn"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="//fs:Atc/@DN"/></xsl:otherwise>
								</xsl:choose>
							</td>
						</xsl:if>
						<xsl:if test="//fs:Atc/@V"><td width="25%"><xsl:value-of select="//fs:Atc/@V"/></td></xsl:if>
						<xsl:if test="//fs:Reseptgruppe"><td width="25%"><xsl:value-of select="//fs:Reseptgruppe/@V"/></td></xsl:if>
					</tr>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="//fs:Varenr or m1:Antall or //fs:Pakningsinfo or m1:Reiterasjon">
			<tr>
				<xsl:if test="//fs:Varenr"><th width="25%">Varenummer</th></xsl:if>
				<xsl:choose>
					<xsl:when test="m1:Antall and //fs:Pakningsinfo"><th width="25%">Antall/Pakningsinfo</th></xsl:when>
					<xsl:when test="m1:Antall and //fs:PakningsinfoResept"><th width="25%">Antall/PakningsinfoResept</th></xsl:when>
					<xsl:when test="//fs:PakningsinfoResept"><th width="25%">PakningsinfoResept</th></xsl:when>
					<xsl:when test="//fs:Pakningsinfo"><th width="25%">Pakningsinfo</th></xsl:when>
					<xsl:when test="m1:Antall"><th width="25%">Antall</th></xsl:when>
				</xsl:choose>
				<xsl:if test="m1:Reiterasjon"><th width="25%">Reit</th></xsl:if>
			</tr>
			<tr>
				<xsl:if test="//fs:Varenr"><td width="25%"><xsl:value-of select="//fs:Varenr"/></td></xsl:if>
				<xsl:choose>
					<xsl:when test="m1:Antall and //fs:Pakningsinfo"><td width="25%">
						<xsl:value-of select="m1:Antall"/>pk&#160;á&#160;<xsl:value-of select="//fs:Pakningsinfo/fs:Pakningsstr"/><xsl:value-of select="//fs:Pakningsinfo/fs:EnhetPakning/@DN"/></td>
					</xsl:when>
					<xsl:when test="m1:Antall and //fs:PakningsinfoResept"><td width="25%">
						<xsl:value-of select="m1:Antall"/>pk&#160;á&#160;<xsl:value-of select="//fs:PakningsinfoResept/fs:Pakningsstr"/><xsl:value-of select="//fs:PakningsinfoResept/fs:EnhetPakning/@DN"/></td>
					</xsl:when>
					<xsl:when test="//fs:PakningsinfoResept"><td width="25%">
						<xsl:value-of select="//fs:PakningsinfoResept/fs:Pakningsstr"/><xsl:value-of select="//fs:PakningsinfoResept/fs:EnhetPakning/@DN"/></td>
					</xsl:when>
					<xsl:when test="//fs:Pakningsinfo"><td width="25%">
						<xsl:value-of select="//fs:Pakningsinfo/fs:Pakningsstr"/><xsl:value-of select="//fs:Pakningsinfo/fs:EnhetPakning/@DN"/></td>
					</xsl:when>
					<xsl:when test="m1:Antall"><td width="25%">
						<xsl:value-of select="m1:Antall"/>pk</td>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="m1:Reiterasjon"><td width="25%"><xsl:value-of select="m1:Reiterasjon"/></td></xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="//fs:DosVeiledEnkel or //fs:Bruksomrade or //fs:Bruk or //fs:IngenKombinasjon">
			<tr>
				<xsl:if test="//fs:DosVeiledEnkel"><th width="25%">Doseringsveiledning</th></xsl:if>
				<xsl:if test="//fs:Bruksomrade"><th width="25%">Bruksområde</th></xsl:if>
				<xsl:if test="//fs:Bruk"><th width="25%">Bruk</th></xsl:if>
				<xsl:if test="//fs:IngenKombinasjon"><th width="25%">Kombinasjon</th></xsl:if>
			</tr>
			<tr>
				<xsl:if test="//fs:DosVeiledEnkel"><td width="25%"><xsl:value-of select="//fs:DosVeiledEnkel"/></td></xsl:if>
				<xsl:if test="//fs:Bruksomrade"><td width="25%"><xsl:value-of select="//fs:Bruksomrade"/></td></xsl:if>
				<xsl:if test="//fs:Bruk">
					<td width="25%">
						<xsl:choose>
							<xsl:when test="//fs:Bruk/@DN"><xsl:value-of select="//fs:Bruk/@DN"/></xsl:when>
							<xsl:otherwise><b>Kodet: </b><xsl:value-of select="//fs:Bruk/@V"/></xsl:otherwise>
						</xsl:choose>
					</td>
				</xsl:if>
				<xsl:if test="//fs:IngenKombinasjon">
					<xsl:choose>
						<xsl:when test="//fs:IngenKombinasjon='true'">
							<td>Skal ikke tas sammen med andre legemiddel</td>
						</xsl:when>
						<xsl:otherwise>
							<td>Kan tas sammen med andre legemiddel</td>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="m1:ReseptDokHandelsvare">
		<xsl:if test="m1:ProdGruppe or //fs:Navn or m1:Antall or //fs:ProduktInfoVare or //fs:Atc">
			<tr>
				<xsl:choose>
					<xsl:when test="m1:ProdGruppe and //fs:Navn"><th width="25%">Produktgruppe/Navn</th></xsl:when>
					<xsl:otherwise>
						<xsl:if test="m1:ProdGruppe"><th width="25%">Produktgruppe</th></xsl:if>
						<xsl:if test="//fs:Navn"><th width="25%">Navn</th></xsl:if>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="m1:Antall"><th width="25%">Antall</th></xsl:if>
				<xsl:if test="//fs:Atc"><th width="25%">Atc</th></xsl:if>
			</tr>
			<tr>
				<xsl:choose>
					<xsl:when test="m1:ProdGruppe and //fs:Navn">
						<td width="25%">
							<xsl:choose>
								<xsl:when test="m1:ProdGruppe/@DN">
									<xsl:value-of select="m1:ProdGruppe/@DN"/>
								</xsl:when>
								<xsl:when test="m1:ProdGruppe/@OT">
									<span class="strong">Fritekst:&#160;</span><xsl:value-of select="m1:ProdGruppe/@OT"/>
								</xsl:when>
								<xsl:otherwise>
									<span class="strong">Kodet:&#160;</span><xsl:value-of select="m1:ProdGruppe/@V"/>
								</xsl:otherwise>
							</xsl:choose>
							/<xsl:value-of select="//fs:Navn"/>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="m1:ProdGruppe">
							<td width="25%">
								<xsl:choose>
									<xsl:when test="m1:ProdGruppe/@DN">
										<xsl:value-of select="m1:ProdGruppe/@DN"/>
									</xsl:when>
									<xsl:when test="m1:ProdGruppe/@OT">
										<span class="strong">Fritekst:&#160;</span><xsl:value-of select="m1:ProdGruppe/@OT"/>
									</xsl:when>
									<xsl:otherwise>
										<span class="strong">Kodet:&#160;</span><xsl:value-of select="m1:ProdGruppe/@V"/>
									</xsl:otherwise>
								</xsl:choose>
							</td>
						</xsl:if>
						<xsl:if test="//fs:Navn"><td width="25%"><xsl:value-of select="//fs:Navn"/></td></xsl:if>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="m1:Antall"><td width="25%">
					<xsl:value-of select="m1:Antall"/>
					<xsl:choose>
						<xsl:when test="//fs:ProduktInfoVare">pk</xsl:when>
						<xsl:otherwise>stk</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="//fs:ProduktInfoVare/fs:AntPerPakning">&#160;á&#160;<xsl:value-of select="//fs:ProduktInfoVare/fs:AntPerPakning"/><xsl:value-of select="//fs:ProduktInfoVare/fs:EnhetStorrelse/@DN"/></xsl:if>
				</td></xsl:if>
				<xsl:if test="//fs:Atc"><td width="25%"><xsl:value-of select="//fs:Atc/@V"/>&#160;&#160;<xsl:value-of select="//fs:Atc/@DN"/></td></xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="//fs:Reseptgruppe or //fs:Varenr">
			<tr>
				<xsl:if test="//fs:Reseptgruppe"><th width="25%">Reseptgruppe</th></xsl:if>
				<xsl:if test="//fs:Varenr"><th width="25%">Varenummer</th></xsl:if>
			</tr>
			<tr>
				<xsl:if test="//fs:Reseptgruppe"><td width="25%">
					<xsl:choose>
						<xsl:when test="//fs:Reseptgruppe/@DN"><xsl:value-of select="//fs:Reseptgruppe/@DN"/></xsl:when>
						<xsl:otherwise><b>Kodet: </b><xsl:value-of select="//fs:Reseptgruppe/@V"/></xsl:otherwise>
					</xsl:choose></td>
				</xsl:if>
				<xsl:if test="//fs:Varenr"><td width="25%"><xsl:value-of select="//fs:Varenr"/></td></xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="m1:Bruksveiledning">
			<tr>
				<th width="25%">Bruksveiledning</th>
			</tr>
			<tr>
				<td width="25%"><xsl:value-of select="m1:Bruksveiledning"/></td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="fs:Dosering">
		<h2>Dosering<xsl:if test="//fs:DoseEtterBehov">&#160;ved&#160;behov</xsl:if>
			<xsl:if test="//fs:Mengde">
				<font size="2">- Doseringsenhet:&#160;
					<xsl:choose>
						<xsl:when test="string(number(//fs:Mengde/@U)) != 'NaN'"><!-- //fs:Mengde/@U er et tall -->
							<xsl:for-each select="//fs:Mengde/@U">
								<xsl:call-template name="k-7480"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="//fs:Mengde/@U"/>
						</xsl:otherwise>
					</xsl:choose>
				</font>
			</xsl:if>
		</h2>
		<table>
			<tbody>
				<xsl:variable name="doseringOK">
					<xsl:for-each select="//fs:Dosering">
						<xsl:variable name="intervallNrEn">
							<xsl:choose>
								<xsl:when test="fs:DoseFastTidspunkt/fs:Intervall/@V and string-length(fs:DoseFastTidspunkt/fs:Intervall/@V)!=0">
									<xsl:value-of select="fs:DoseFastTidspunkt/fs:Intervall/@V"/>
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="count(.//fs:Intervall)!=count(.//fs:Intervall[@V=$intervallNrEn])  or not(fs:Starttidspunkt/@V) or string-length(fs:Starttidspunkt/@V) = 0 or fs:DoseFastTidspunkt[fs:FastDose]/fs:Intervall or fs:DoseFastTidspunkt[fs:Infusjonshastighet]/fs:Intervall or fs:DoseFastTidspunkt[fs:Infusjonshastighet]/fs:Tidsomrade or fs:DoseFastTidspunkt[fs:Tidsomrade]/fs:Klokkeslett or fs:DoseFastTidspunkt[fs:Tidsomrade]/fs:Klokkeslett or fs:DoseFastTidspunkt/fs:Intervall[@U != 'Døgn']">nei</xsl:when>
							<xsl:otherwise>ja</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>
			
				<xsl:choose>
					<xsl:when test="//fs:Dosering and not(contains($doseringOK, 'nei'))">
						<xsl:for-each select="//fs:Dosering/fs:Doseringsregel">
							<xsl:if test="position()=1">
								<tr>
									<th width="25%">Doseringsregel</th>
									<xsl:if test="fs:Merknad"><th colspan="8">Merknad</th></xsl:if>
								</tr>
								<tr>
									<td width="25%">Doseres&#160;etter:&#160;
										<xsl:choose>
											<xsl:when test="fs:DoseresEtter/@DN">
												<xsl:value-of select="fs:DoseresEtter/@DN"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:for-each select="fs:DoseresEtter">
													<xsl:call-template name="k-9080"/>
												</xsl:for-each>
											</xsl:otherwise>
										</xsl:choose>
									</td>
									<xsl:if test="fs:Merknad"><td colspan="8"><xsl:value-of select="fs:Merknad"/></td></xsl:if>
								</tr>
							</xsl:if>
						</xsl:for-each>
						<xsl:for-each select="//fs:Dosering">
							<xsl:if test="fs:DoseFastTidspunkt">
								<xsl:variable name="currentTimeDose">
									<xsl:for-each select="fs:DoseFastTidspunkt">
										<xsl:value-of select="fs:Tidsomrade/@V"/>
										<xsl:value-of select="fs:Klokkeslett"/>
									</xsl:for-each>
								</xsl:variable>
								<xsl:variable name="previousTimeDose">
									<xsl:for-each select="preceding-sibling::fs:Dosering[1]"> <!-- Velger forrige Dosering-node -->
										<xsl:for-each select="fs:DoseFastTidspunkt">
											<xsl:value-of select="fs:Tidsomrade/@V"/>
											<xsl:value-of select="fs:Klokkeslett"/>
										</xsl:for-each>
									</xsl:for-each>
								</xsl:variable>
	
								<!-- Variabler for beregning av antall kolonner i doseringstabell -->
								<xsl:variable name="unionOmrade"> <!-- Samler og sorterer tidsområdene i en union -->
									<xsl:for-each select="fs:DoseFastTidspunkt">
										<xsl:sort select="fs:Tidsomrade/@V"/>
										<xsl:value-of select="fs:Tidsomrade/@V"/>
									</xsl:for-each>
								</xsl:variable>
								<xsl:variable name="unionUnikOmrade"> <!-- Union av tidsområder etter at duplikat er fjernet -->
									<xsl:call-template name="unikeOmraderKalkulator">
										<xsl:with-param name="streng" select="$unionOmrade"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="unionKlokke"> <!-- Samler og sorterer klokkeslettene i en union -->
									<xsl:for-each select="fs:DoseFastTidspunkt">
										<xsl:sort select="fs:Klokkeslett"/>
										<xsl:for-each select="fs:Klokkeslett">
											<xsl:variable name="tempKlokke">
												<xsl:call-template name="skrivUtTime"><xsl:with-param name="oppgittTid" select="."/></xsl:call-template> <!-- Omgjør klokkeslett til 8 tegn, f.eks. 'kl.10:00', og fjerner (ignorerer) tidssoner -->
											</xsl:variable>
											<xsl:value-of select="normalize-space($tempKlokke)"/> <!-- Fjerner whitespace foran og bak -->
										</xsl:for-each>
									</xsl:for-each>
								</xsl:variable>
								<xsl:variable name="unionUnikKlokke"> <!-- Union av klokkeslett etter at duplikat er fjernet -->
									<xsl:call-template name="unikeKlokkerKalkulator">
										<xsl:with-param name="streng" select="$unionKlokke"/>
									</xsl:call-template>
								</xsl:variable>
						
								<!-- Skriver header-linjer kun hvis tidspunkt for dosering har endret seg siden forrige dosering -->
								<xsl:if test="not($currentTimeDose=$previousTimeDose) and not(starts-with($previousTimeDose, $currentTimeDose))">
									<tr>
										<xsl:if test="fs:Starttidspunkt"><th>Dato</th></xsl:if>
										<xsl:if test=".//fs:Infusjonshastighet"><th>Infusjonshastighet</th></xsl:if>
										<xsl:if test=".//fs:Tidsomrade">
											<xsl:call-template name="fyllOmraderHeader">
												<xsl:with-param name="streng" select="$unionUnikOmrade"/>
											</xsl:call-template>
										</xsl:if>
										<xsl:if test=".//fs:Klokkeslett">
											<xsl:call-template name="fyllKlokkeHeader">
												<xsl:with-param name="streng" select="$unionUnikKlokke"/>
											</xsl:call-template>
										</xsl:if>
									</tr>
								</xsl:if>
									
								<xsl:call-template name="fyllDoseFastTidspunkt">
									<xsl:with-param name="start">
										<xsl:call-template name="skrivUtDateJustert">
											<xsl:with-param name="oppgittTid" select="fs:Starttidspunkt/@V"/>
											<xsl:with-param name="xAntall" select="0"/>
										</xsl:call-template>
									</xsl:with-param>
									<xsl:with-param name="slutt">
										<xsl:call-template name="skrivUtDateJustert">
											<xsl:with-param name="oppgittTid" select="fs:Sluttidspunkt/@V"/>
											<xsl:with-param name="xAntall" select="0"/> <!-- Vil gi tom tabell om start- og sluttdato er like. Legg til "1" her om sluttdato er 'til og med' istedet for 'til' -->
										</xsl:call-template>
									</xsl:with-param>
									<xsl:with-param name="teller" select="1"/>
									<xsl:with-param name="intervall">
										<xsl:choose>
											<xsl:when test="fs:DoseFastTidspunkt/fs:Intervall/@V and fs:DoseFastTidspunkt/fs:Intervall/@U = 'Døgn'"><xsl:value-of select="fs:DoseFastTidspunkt/fs:Intervall/@V"/></xsl:when>
											<xsl:otherwise>0</xsl:otherwise>
										</xsl:choose>
									</xsl:with-param>
									<xsl:with-param name="teller2" select="1"/>
									<xsl:with-param name="fastDagerPaa">
										<xsl:choose>
											<xsl:when test="fs:DoseFastTidspunkt/fs:FastDose/fs:DagerPa"><xsl:value-of select="fs:DoseFastTidspunkt/fs:FastDose/fs:DagerPa"/></xsl:when>
											<xsl:otherwise>0</xsl:otherwise>
										</xsl:choose>
									</xsl:with-param>
									<xsl:with-param name="fastDagerAv">
										<xsl:choose>
											<xsl:when test="fs:DoseFastTidspunkt/fs:FastDose/fs:DagerAv"><xsl:value-of select="fs:DoseFastTidspunkt/fs:FastDose/fs:DagerAv"/></xsl:when>
											<xsl:otherwise>0</xsl:otherwise>
										</xsl:choose>
									</xsl:with-param>
									<xsl:with-param name="fasteUkedager">
										<xsl:choose>
											<xsl:when test="fs:DoseFastTidspunkt/fs:FastDose/fs:FasteUkedager">
												<xsl:for-each select=".//fs:FasteUkedager">
													<xsl:value-of select="@V"/>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>0</xsl:otherwise>
										</xsl:choose>
									</xsl:with-param>
									<xsl:with-param name="nyDose" select="1"/>
								</xsl:call-template>
							</xsl:if>
						
							<xsl:if test="fs:DoseEtterBehov">
								<xsl:if test="position()=1">
									<!-- Doseringstabell -->
									<tr>
										<xsl:if test="..//fs:Starttidspunkt"><th>Start</th></xsl:if>
										<xsl:if test="..//fs:Sluttidspunkt"><th>Slutt</th></xsl:if>
										<xsl:if test="..//fs:Mengde"><th>Enkeltdose</th></xsl:if>
										<xsl:if test="..//fs:Infusjonshastighet"><th>Infusjonshastighet</th></xsl:if>
										<xsl:if test="..//fs:DoseDognMaks"><th>Maks&#160;døgndose</th></xsl:if>
										<xsl:if test="..//fs:DoseTidsromMaks"><th>Maks&#160;dose i&#160;tidsrom</th></xsl:if>
										<xsl:if test="..//fs:Tidsrom"><th>Tidsrom&#160;for maks&#160;dose</th></xsl:if>
										<xsl:if test="..//fs:DoseIntervallMin"><th>Minimum&#160;dose innenfor&#160;tidsintervall</th></xsl:if>
										<xsl:if test="..//fs:Intervall"><th>Tidsintervall</th></xsl:if>
									</tr>
								</xsl:if>
								<tr>
									<xsl:if test="..//fs:Starttidspunkt">
										<td width="25%">
											<xsl:if test="fs:Starttidspunkt">
												<xsl:call-template name="skrivUtDateJustert">
													<xsl:with-param name="oppgittTid" select="fs:Starttidspunkt/@V"/>
													<xsl:with-param name="xAntall" select="0"/>
												</xsl:call-template>
											</xsl:if>
										</td>
									</xsl:if>
									<xsl:if test="..//fs:Sluttidspunkt">
										<td width="25%">
											<xsl:if test="fs:Sluttidspunkt">
												<xsl:call-template name="skrivUtDateJustert">
													<xsl:with-param name="oppgittTid" select="fs:Sluttidspunkt/@V"/>
													<xsl:with-param name="xAntall" select="0"/>
												</xsl:call-template>
											</xsl:if>
										</td>
									</xsl:if>
									<xsl:if test="..//fs:Mengde">
										<td width="25%">
											<xsl:choose>
												<xsl:when test=".//fs:Mengde">
													<xsl:value-of select=".//fs:Mengde/@V"/>&#160;<xsl:value-of select=".//fs:Mengde/@U"/>
												</xsl:when>
												<xsl:otherwise>-</xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:if>
									<xsl:if test="..//fs:Infusjonshastighet">
										<td width="25%">
											<xsl:choose>
												<xsl:when test=".//fs:Infusjonshastighet">
													<xsl:value-of select=".//fs:Infusjonshastighet/fs:Volum/@V"/>&#160;<xsl:value-of select=".//fs:Infusjonshastighet/fs:Volum/@U"/>/<xsl:value-of select=".//fs:Infusjonshastighet/fs:Tidsenhet/@V"/>
												</xsl:when>
												<xsl:otherwise>-</xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:if>
									<xsl:if test="..//fs:DoseDognMaks">
										<td width="25%">
											<xsl:choose>
												<xsl:when test=".//fs:DoseDognMaks">
													<xsl:value-of select=".//fs:DoseDognMaks/@V"/>&#160;<xsl:value-of select=".//fs:DoseDognMaks/@U"/>
												</xsl:when>
												<xsl:otherwise>-</xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:if>
									<xsl:if test="..//fs:DoseTidsromMaks">
										<td width="25%">
											<xsl:choose>
												<xsl:when test=".//fs:DoseTidsromMaks">
													<xsl:value-of select=".//fs:DoseTidsromMaks/@V"/>&#160;<xsl:value-of select=".//fs:DoseTidsromMaks/@U"/>
												</xsl:when>
												<xsl:otherwise>-</xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:if>
									<xsl:if test="..//fs:Tidsrom">
										<td width="25%">
											<xsl:choose>
												<xsl:when test=".//fs:Tidsrom">
													<xsl:value-of select=".//fs:Tidsrom/@V"/>&#160;<xsl:value-of select=".//fs:Tidsrom/@U"/>
												</xsl:when>
												<xsl:otherwise>-</xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:if>
									<xsl:if test="..//fs:DoseIntervallMin">
										<td width="25%">
											<xsl:choose>
												<xsl:when test=".//fs:DoseIntervallMin">
													<xsl:value-of select=".//fs:DoseIntervallMin/@V"/>&#160;<xsl:value-of select=".//fs:DoseIntervallMin/@U"/>
												</xsl:when>
												<xsl:otherwise>-</xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:if>
									<xsl:if test="..//fs:Intervall">
										<td width="25%">
											<xsl:choose>
												<xsl:when test=".//fs:Intervall">
													<xsl:value-of select=".//fs:Intervall/@V"/>&#160;<xsl:value-of select=".//fs:Intervall/@U"/>
												</xsl:when>
												<xsl:otherwise>-</xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:if>
								</tr>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="//fs:Dosering">
							<xsl:if test="position()=string-length(substring-before($doseringOK, 'nei'))+1">
								<xsl:variable name="intervall">
									<xsl:choose>
										<xsl:when test="fs:DoseFastTidspunkt/fs:Intervall/@V and string-length(fs:DoseFastTidspunkt/fs:Intervall/@V)!=0">
											<xsl:value-of select="fs:DoseFastTidspunkt/fs:Intervall/@V"/>
										</xsl:when>
										<xsl:otherwise>0</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<tr>
									<td colspan="3">
										<span class="strong">Doseringen som er angitt på legemidlet er ikke mulig å vise. Kontakt forskrivende lege!</span><br/>
										Årsak:
										<xsl:if test="count(.//fs:Intervall)!=count(.//fs:Intervall[@V=$intervall])">
											Forskjellige døgnintervall.&#160;
										</xsl:if>
										<xsl:if test="not(fs:Starttidspunkt/@V) or string-length(fs:Starttidspunkt/@V) = 0">
											Starttidspunkt mangler.&#160;
										</xsl:if>
										<xsl:if test="fs:DoseFastTidspunkt[fs:FastDose]/fs:Intervall">
											Både Fast dose og Intervall er oppgitt.&#160;
										</xsl:if>
										<xsl:if test="fs:DoseFastTidspunkt[fs:Infusjonshastighet]/fs:Intervall">
											Både Infusjonshastighet og Intervall er oppgitt.&#160;
										</xsl:if>
										<xsl:if test="fs:DoseFastTidspunkt[fs:Infusjonshastighet]/fs:Tidsomrade">
											Både Infusjonshastighet og Tidsområde er oppgitt.&#160;
										</xsl:if>
										<xsl:if test="fs:DoseFastTidspunkt[fs:Infusjonshastighet]/fs:Klokkeslett">
											Både Infusjonshastighet og Tidsområde er oppgitt.&#160;
										</xsl:if>
										<xsl:if test="fs:DoseFastTidspunkt[fs:Tidsomrade]/fs:Klokkeslett">
											Både Tidsområde og Klokkeslett er oppgitt.&#160;
										</xsl:if>
										<xsl:if test="fs:DoseFastTidspunkt/fs:Intervall[@U != 'Døgn']">
											Visningen håndterer kun intervall oppgitt i 'Døgn'.&#160;
										</xsl:if>
									</td>
								</tr>
							</xsl:if>
						</xsl:for-each>
					
					</xsl:otherwise>
				</xsl:choose>

			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="m1:LegemiddelUtenMt">
		<h2>Søknad SLV
			<xsl:choose>
				<xsl:when test="string-length($vedlegg) != 0 and count($vedlegg//m15:SvarSLV) != 0">
					&#160;-&#160;
					<xsl:choose>
						<xsl:when test="/.//mh:MsgId = $vedlegg//m15:ReseptId">
							<xsl:if test="$vedlegg//m15:Innvilget/@V = 1">Innvilget</xsl:if>
							<xsl:if test="$vedlegg//m15:Innvilget/@V = 2">Avslått</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							Vedlagte søknadssvars referanseid ikke i samsvar med reseptid
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</h2>
		<table>
			<tbody>
				<tr>
					<th width="15%">Produsent</th>
					<th width="10%">Direktesøknad</th>
					<th>Begrunnelse</th>
				</tr>
				<tr>
					<td width="15%"><xsl:value-of select="m1:Produsent"/></td>
					<td width="10%">
						<xsl:choose>
							<xsl:when test="m1:DirektesoknadSlv='true'">Ja</xsl:when>
							<xsl:otherwise>Nei</xsl:otherwise>
						</xsl:choose>
					</td>
					<td>
					<xsl:choose>
						<xsl:when test="string-length($vedlegg) !=0 and count($vedlegg//m15:SvarSLV)!=0">	
							<xsl:choose>
								<xsl:when test="/.//mh:MsgId = $vedlegg//m15:ReseptId">
									<xsl:if test="$vedlegg//m15:Innvilget/@V = 1"><xsl:value-of select="m1:Begrunnelse"/></xsl:if>
									<xsl:if test="$vedlegg//m15:Innvilget/@V = 2"><xsl:value-of select="$vedlegg//m15:BegrunnelseAvslag"/></xsl:if>
								</xsl:when>
							<xsl:otherwise>
								Vedlagte søknadssvars referanseid ikke i samsvar med reseptid
							</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
					</xsl:choose>
					</td>
				</tr>
			</tbody>
		</table>
		<p/>
	</xsl:template>
	
	<xsl:template match="m1:Instituert">
		<h2>Instituert av</h2>
		<table>
			<tbody>
				<xsl:if test="m1:Organisasjon">
					<tr>
						<th width="25%">HER-id</th>
						<xsl:if test="m1:Organisasjon/m1:Inst"><th width="25%">Inst</th></xsl:if>
						<xsl:if test="m1:Organisasjon/m1:Dept"><th width="25%">Dept</th></xsl:if>
					</tr>
					<tr>
						<td width="25%"><xsl:value-of select="m1:Organisasjon/m1:HerId/fk1:Id"/></td>
						<xsl:if test="m1:Organisasjon/m1:Inst"><td width="25%"><xsl:value-of select="m1:Organisasjon/m1:Inst"/></td></xsl:if>
						<xsl:if test="m1:Organisasjon/m1:Dept"><td width="25%"><xsl:value-of select="m1:Organisasjon/m1:Dept"/></td></xsl:if>
					</tr>
				</xsl:if>
				<xsl:if test="m1:Helseperson">
					<tr>
						<th width="25%">HPR-id</th>
						<xsl:if test="m1:Helseperson/m1:Fornavn or m1:Helseperson/m1:Etternavn"><th width="25%">Navn</th></xsl:if>
						<xsl:if test="m1:Helseperson/m1:Spesialitet"><th width="25%">Spesialitet</th></xsl:if>
					</tr>
					<tr>
						<td width="25%"><xsl:value-of select="m1:Helseperson/m1:HprId/fk1:Id"/></td>
						<xsl:if test="m1:Helseperson/m1:Fornavn or m1:Helseperson/m1:Etternavn"><td width="25%"><xsl:value-of select="m1:Helseperson/m1:Fornavn"/>&#160;<xsl:value-of select="m1:Helseperson/m1:Etternavn"/></td></xsl:if>
						<xsl:if test="m1:Helseperson/m1:Spesialitet"><td width="25%">
							<xsl:choose>
								<xsl:when test="m1:Helseperson/m1:Spesialitet/@DN"><xsl:value-of select="m1:Helseperson/m1:Spesialitet/@DN"/></xsl:when>
								<xsl:otherwise><b>Kodet: </b><xsl:value-of select="m1:Helseperson/m1:Spesialitet/@V"/></xsl:otherwise>
							</xsl:choose>
						</td></xsl:if>
					</tr>
				</xsl:if>
			</tbody>
		</table>
		<p/>
	</xsl:template>
	
	<xsl:template match="m1:EkspAnm">
		<h2>Ekspederingsanmodning - 
			<xsl:choose>
				<xsl:when test="m1:MetodeEkspedering/@DN"><xsl:value-of select="m1:MetodeEkspedering/@DN"/></xsl:when>
				<xsl:otherwise><b>Metode - Kodet: </b><xsl:value-of select="m1:MetodeEkspedering/@V"/></xsl:otherwise>
			</xsl:choose>
		</h2>
		<table>
			<tbody>
				<tr>
					<th width="25%">Utleverernavn</th>
					<th width="25%">Kontaktperson</th>
					<xsl:if test="m1:Adresse"><th width="25%">Adresse</th></xsl:if>
				</tr>
				<tr>
					<td width="25%"><xsl:value-of select="m1:UtlevererNavn"/></td>
					<td width="25%"><xsl:value-of select="m1:Kontaktperson"/></td>
					<xsl:if test="m1:Adresse"><td width="25%" rowspan="3" valign="top">
						<xsl:if test="m1:Adresse/fk1:StreetAdr"><div><xsl:value-of select="m1:Adresse/fk1:StreetAdr"/></div></xsl:if>
						<xsl:if test="m1:Adresse/fk1:PostalCode or m1:Adresse/fk1:City"><div><xsl:value-of select="m1:Adresse/fk1:PostalCode"/>&#160;<xsl:value-of select="m1:Adresse/fk1:City"/></div></xsl:if>
						<xsl:if test="m1:Adresse/fk1:Postbox"><div>Postboks:&#160;<xsl:value-of select="m1:Adresse/fk1:Postbox"/></div></xsl:if>
						<xsl:if test="m1:Adresse/fk1:County"><div><xsl:value-of select="m1:Adresse/fk1:County/@DN"/></div></xsl:if>
						<xsl:if test="m1:Adresse/fk1:Country"><div><xsl:value-of select="m1:Adresse/fk1:Country/@DN"/></div></xsl:if>
					</td></xsl:if>
				</tr>
				<tr>
					<th width="25%">Utleverer</th>
					<th width="25%">Orgnr. utlev.</th>
				</tr>
				<tr>
					<td width="25%"><xsl:value-of select="m1:Utleverer"/></td>
					<td width="25%"><xsl:value-of select="m1:OrgNrUtleverer"/></td>
				</tr>
				<xsl:if test="m1:Merknad">
					<tr>
						<th colspan="3">Merknad</th>
					</tr>
					<tr>
						<xsl:choose>
							<xsl:when test="m1:Adresse"><td colspan="3"><xsl:value-of select="m1:Merknad"/></td></xsl:when>
							<xsl:otherwise><td colspan="2"><xsl:value-of select="m1:Merknad"/></td></xsl:otherwise>
						</xsl:choose>
					</tr>
				</xsl:if>
			</tbody>
		</table>
		<p/>
	</xsl:template>
	
	<xsl:template match="m1:Utlending">
		<h2>Utlending</h2>
		<table>
			<tbody>
				<xsl:if test="m1:ArbeidstakerNorge or m1:Konvensjonsland/@DN or m1:EEA/m1:EOSDok/@DN">
					<tr>
						<xsl:if test="m1:ArbeidstakerNorge"><th width="25%">ArbeidstakerNorge</th></xsl:if>
						<xsl:if test="m1:Konvensjonsland"><th width="25%">Konvensjonsland</th></xsl:if>
						<xsl:if test="m1:EEA/m1:EOSDok"><th width="25%">EOSDok</th></xsl:if>
					</tr>
					<tr>
						<xsl:if test="m1:ArbeidstakerNorge"><td width="25%"><xsl:value-of select="m1:ArbeidstakerNorge"/></td></xsl:if>
						<xsl:if test="m1:Konvensjonsland"><td width="25%">
							<xsl:choose>
								<xsl:when test="m1:Konvensjonsland/@DN"><xsl:value-of select="m1:Konvensjonsland/@DN"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="m1:Konvensjonsland/@V"/></xsl:otherwise>
							</xsl:choose>
						</td></xsl:if>
						<xsl:if test="m1:EEA/m1:EOSDok"><td width="25%">
							<xsl:choose>
								<xsl:when test="m1:EEA/m1:EOSDok/@DN"><xsl:value-of select="m1:EEA/m1:EOSDok/@DN"/></xsl:when>
								<xsl:otherwise><b>Kodet: </b><xsl:value-of select="m1:EEA/m1:EOSDok/@V"/></xsl:otherwise>
							</xsl:choose>
						</td></xsl:if>
					</tr>
				</xsl:if>
				<xsl:if test="m1:EEA/m1:EEACardId or m1:EEA/m1:EEAId">
					<tr>
						<xsl:if test="m1:EEA/m1:EEACardId"><th width="25%">EEACardId</th></xsl:if>
						<xsl:if test="m1:EEA/m1:EEAId"><th width="25%">EEAId</th></xsl:if>
					</tr>
					<tr>
						<xsl:if test="m1:EEA/m1:EEACardId"><td width="25%"><xsl:value-of select="m1:EEA/m1:EEACardId"/></td></xsl:if>
						<xsl:if test="m1:EEA/m1:EEAId"><td width="25%"><xsl:value-of select="m1:EEA/m1:EEAId"/></td></xsl:if>
					</tr>
				</xsl:if>
			</tbody>
		</table>
		<p/>
	</xsl:template>
	
	<!-- Funksjoner -->

	<!-- Rekursiv funksjon som fyller ut doseringstabellen -->
	<xsl:template name="fyllDoseFastTidspunkt">
		<xsl:param name="start"/> <!-- Startdato for doseringen. For hvert rekursive kall, legges til en dag inntil sluttdato er nådd -->
		<xsl:param name="slutt"/> <!-- Sluttdato for doseringen. Inneholder minus "-" om sluttdato ikke er oppgitt-->
		<xsl:param name="teller"/> <!-- teller = 0: Exit. teller = 1: Vanlig dosering. teller > 1: Opphold i dosering -->
		<xsl:param name="intervall"/> <!-- Antall tidsenheter som skal gå mellom hver gang tiltakes skal gjentas. Håndterer kun U='Døgn'. 0 om ikke i bruk -->
		<xsl:param name="teller2"/> <!-- Teller som starter på 1. Legges til 1 for hvert rekursive kall. Brukes ifm. fastDagerPaa/Av og fasteUkedager for å holde styr på ukedagene. -->
		<xsl:param name="fastDagerPaa"/> <!-- Antall dager et legemiddel skal brukes i strekk -->
		<xsl:param name="fastDagerAv"/> <!-- Antall dager et legemiddel ikke skal brukes i strekk -->
		<xsl:param name="fasteUkedager"/> <!-- Samling av alle ukedagene hvor dose skal tas. F.eks. 137 (mandag, onsdag, søndag). 0 om ikke i bruk -->
		<xsl:param name="nyDose"/> <!-- nyDose = 1: Merkes med 'Ny dose' i doseringstabellen -->
		<xsl:variable name="ukedag"> <!-- Holder dagen for gitt dato. 1 = mandag, 7 = søndag -->
			<xsl:call-template name="kalkulerUkedag">
				<xsl:with-param name="oppgittDato">
					<xsl:call-template name="skrivUtDateReversert">
						<xsl:with-param name="oppgittTid" select="$start"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="not(contains($start, $slutt))"> <!-- Avslutter om sluttdato er nådd -->
			<tr>
				<xsl:if test="..//fs:Starttidspunkt">
					<td width="25%">
						<xsl:value-of select="$start"/>&#160;
						<xsl:if test="$fasteUkedager &gt; 0">
							<xsl:call-template name="k-9082">
								<xsl:with-param name="ukedag" select="$ukedag"/>
							</xsl:call-template>&#160;
						</xsl:if>
						<xsl:if test="$nyDose =1">
							<xsl:if test="not($fasteUkedager &gt; 0 and not(contains($fasteUkedager, $ukedag)))">Ny&#160;dose!</xsl:if>
						</xsl:if>
					</td>
				</xsl:if>
				<xsl:if test="..//fs:Infusjonshastighet">
					<td>
						<xsl:choose>
							<xsl:when test=".//fs:Infusjonshastighet">
								<xsl:value-of select=".//fs:Infusjonshastighet/fs:Volum/@V"/>&#160;<xsl:value-of select=".//fs:Infusjonshastighet/fs:Volum/@U"/>/<xsl:value-of select=".//fs:Infusjonshastighet/fs:Tidsenhet/@V"/>
							</xsl:when>
							<xsl:otherwise>-</xsl:otherwise>
						</xsl:choose>
					</td>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$teller != 1 or ($fasteUkedager &gt; 0 and not(contains($fasteUkedager, $ukedag)))"> <!-- Utfylling av dager med opphold --> 
						<xsl:call-template name="fyllDager">
							<xsl:with-param name="ukedag" select="$ukedag"/>
							<xsl:with-param name="teller" select="1"/>
							<xsl:with-param name="fyll" select="0"/>
							<xsl:with-param name="allFyll" select="1"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise> <!-- Vanlig utfylling -->
						<xsl:call-template name="fyllDager">
							<xsl:with-param name="ukedag" select="$ukedag"/>
							<xsl:with-param name="teller" select="1"/>
							<xsl:with-param name="fyll" select="0"/>
							<xsl:with-param name="allFyll" select="0"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</tr>
			<xsl:choose>
				<xsl:when test="($fasteUkedager &gt; 0 and $teller2 != 7 and $fastDagerPaa = 0) or ($fastDagerPaa &gt; 0 and $teller2 != $fastDagerPaa)"><!-- Rader med dager hvor dose skal tas -->
					<xsl:call-template name="fyllDoseFastTidspunkt">
						<xsl:with-param name="start">
							<xsl:call-template name="skrivUtDateJustert">
								<xsl:with-param name="oppgittTid">
									<xsl:call-template name="skrivUtDateReversert">
										<xsl:with-param name="oppgittTid" select="$start"/>
									</xsl:call-template>
								</xsl:with-param>
								<xsl:with-param name="xAntall" select="1"/>
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="slutt" select="$slutt"/>
						<xsl:with-param name="teller" select="$teller"/>
						<xsl:with-param name="intervall" select="$intervall"/>
						<xsl:with-param name="teller2" select="$teller2 + 1"/>
						<xsl:with-param name="fastDagerPaa" select="$fastDagerPaa"/>
						<xsl:with-param name="fastDagerAv" select="$fastDagerAv"/>
						<xsl:with-param name="fasteUkedager" select="$fasteUkedager"/>
						<xsl:with-param name="nyDose">
							<xsl:choose>
								<xsl:when test="$fastDagerPaa &gt; 0 and $teller2 != $fastDagerPaa">0</xsl:when>
								<xsl:when test="$nyDose = 1 and ($fasteUkedager &gt; 0 and not(contains($fasteUkedager, $ukedag)))">1</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="($intervall &gt; 1 and $teller != $intervall) or ($fastDagerAv &gt; 0 and $teller != $fastDagerAv + 1)"> <!-- Rader med dager hvor ingen dose skal tas -->
					<xsl:call-template name="fyllDoseFastTidspunkt">
						<xsl:with-param name="start">
							<xsl:call-template name="skrivUtDateJustert">
								<xsl:with-param name="oppgittTid">
									<xsl:call-template name="skrivUtDateReversert">
										<xsl:with-param name="oppgittTid" select="$start"/>
									</xsl:call-template>
								</xsl:with-param>
								<xsl:with-param name="xAntall" select="1"/>
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="slutt" select="$slutt"/>
						<xsl:with-param name="teller" select="$teller + 1"/>
						<xsl:with-param name="intervall" select="$intervall"/>
						<xsl:with-param name="teller2" select="$teller2"/>
						<xsl:with-param name="fastDagerPaa" select="$fastDagerPaa"/>
						<xsl:with-param name="fastDagerAv" select="$fastDagerAv"/>
						<xsl:with-param name="fasteUkedager" select="$fasteUkedager"/>
						<xsl:with-param name="nyDose" select="0"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$slutt != '-'">
							<xsl:call-template name="fyllDoseFastTidspunkt">
								<xsl:with-param name="start">
									<xsl:call-template name="skrivUtDateJustert">
										<xsl:with-param name="oppgittTid">
											<xsl:call-template name="skrivUtDateReversert">
												<xsl:with-param name="oppgittTid" select="$start"/>
											</xsl:call-template>
										</xsl:with-param>
										<xsl:with-param name="xAntall" select="1"/>
									</xsl:call-template>
								</xsl:with-param>
								<xsl:with-param name="slutt" select="$slutt"/>
								<xsl:with-param name="teller" select="1"/>
								<xsl:with-param name="intervall" select="$intervall"/>
								<xsl:with-param name="teller2" select="$teller2"/>
								<xsl:with-param name="fastDagerPaa" select="$fastDagerPaa"/>
								<xsl:with-param name="fastDagerAv" select="$fastDagerAv"/>
								<xsl:with-param name="fasteUkedager" select="$fasteUkedager"/>
								<xsl:with-param name="nyDose" select="0"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>  <!-- Mangler sluttdato -->
							<!-- Avslutningsrad for doseringer hvor sluttidspunkt ikke er oppgitt -->
							<xsl:if test="position()=last() or following-sibling::fs:Dosering/fs:Starttidspunkt">
								<tr>
									<xsl:choose>
										<xsl:when test="fs:DoseFastTidspunkt/fs:Intervall/@V &gt; 1 or fs:DoseFastTidspunkt/fs:FastDose">
											<td width="25%">Fra&#160;og&#160;med&#160;<xsl:call-template name="skrivUtDateJustert">
													<xsl:with-param name="oppgittTid">
														<xsl:call-template name="skrivUtDateReversert">
															<xsl:with-param name="oppgittTid" select="$start"/>
														</xsl:call-template>
													</xsl:with-param>
													<xsl:with-param name="xAntall" select="1"/>
												</xsl:call-template>, følg&#160;samme&#160;doseringssekvens som&#160;perioden&#160;<xsl:call-template name="skrivUtDateJustert">
													<xsl:with-param name="oppgittTid" select="fs:Starttidspunkt/@V"/>
													<xsl:with-param name="xAntall" select="0"/>
												</xsl:call-template> til <xsl:value-of select="$start"/>
												<xsl:choose>
													<xsl:when test="fs:DoseFastTidspunkt/fs:Intervall/@V &gt; 1">
														<br>1&#160;<xsl:value-of select="fs:DoseFastTidspunkt/fs:Intervall/@U"/>&#160;med&#160;legemiddel</br>
														<xsl:value-of select="fs:DoseFastTidspunkt/fs:Intervall/@V - 1"/>&#160;<xsl:value-of select="fs:DoseFastTidspunkt/fs:Intervall/@U"/>&#160;uten&#160;legemiddel
													</xsl:when>
													<xsl:when test="fs:DoseFastTidspunkt/fs:FastDose/fs:DagerPa">
														<br><xsl:value-of select="fs:DoseFastTidspunkt/fs:FastDose/fs:DagerPa"/>&#160;dag<xsl:if test="fs:DoseFastTidspunkt/fs:FastDose/fs:DagerPa > 1">er</xsl:if>&#160;med&#160;legemiddel</br>
														<xsl:value-of select="fs:DoseFastTidspunkt/fs:FastDose/fs:DagerAv"/>&#160;dag<xsl:if test="fs:DoseFastTidspunkt/fs:FastDose/fs:DagerAv > 1">er</xsl:if>&#160;uten&#160;legemiddel
													</xsl:when>
													<xsl:when test=".//fs:FasteUkedager">
														<br>Faste&#160;ukedager</br>
														<xsl:variable name="unionFasteDager">
															<xsl:for-each select=".//fs:FasteUkedager">
																<xsl:sort select="@V"/>
																<xsl:value-of select="@V"/>
															</xsl:for-each>
														</xsl:variable>
														<xsl:call-template name="unikeFasteDagerKalkulator">
															<xsl:with-param name="streng" select="$unionFasteDager"/>
														</xsl:call-template>
													</xsl:when>
												</xsl:choose>
											</td>
										</xsl:when>
										<xsl:otherwise>
											<td width="25%">Fra&#160;og&#160;med&#160;<xsl:call-template name="skrivUtDateJustert">
													<xsl:with-param name="oppgittTid">
														<xsl:call-template name="skrivUtDateReversert">
															<xsl:with-param name="oppgittTid" select="$start"/>
														</xsl:call-template>
													</xsl:with-param>
													<xsl:with-param name="xAntall" select="1"/>
												</xsl:call-template>, fortsett&#160;med&#160;samme dosering&#160;som&#160;<xsl:value-of select="$start"/>
											</td>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:if test="..//fs:Infusjonshastighet"><td>*</td></xsl:if>
									<xsl:call-template name="fyllDager">
										<xsl:with-param name="ukedag" select="$ukedag"/>
										<xsl:with-param name="teller" select="1"/>
										<xsl:with-param name="fyll" select="'*'"/>
										<xsl:with-param name="allFyll" select="1"/>
									</xsl:call-template>
								</tr>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<!-- Rekursiv funksjon som fyller ut en rad for dagsdosene i doseringstabellen -->
	<xsl:template name="fyllDager">
		<xsl:param name="ukedag"/> <!-- Variabelen inneholder hvilken ukedag raden gjelder for. 1 = mandag, 7 = søndag -->
		<xsl:param name="teller"/> <!-- Variabelen 'teller' traverserer fra 1 til antall kolonner -->
		<xsl:param name="fyll"/> <!-- Variabelen 'fyll' inneholder hva som skal skrives inn i rutene i raden hvis 'allFyll' er satt til true -->
		<xsl:param name="allFyll"/> <!-- Variabelen 'allFyll' er en boolsk variabel som er true (1) om alle rutene skal fylles i raden -->

		<!-- Variabler for beregning av antall kolonner i doseringstabell -->
		<xsl:variable name="unionOmrade"> <!-- Samler og sorterer tidsområdene i en union -->
			<xsl:for-each select="fs:DoseFastTidspunkt">
				<xsl:sort select="fs:Tidsomrade/@V"/>
				<xsl:value-of select="fs:Tidsomrade/@V"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="unionUnikOmrade"> <!-- Union av tidsområder etter at duplikat er fjernet -->
			<xsl:call-template name="unikeOmraderKalkulator">
				<xsl:with-param name="streng" select="$unionOmrade"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="unionKlokke"> <!-- Samler og sorterer klokkeslettene i en union -->
			<xsl:for-each select="fs:DoseFastTidspunkt">
				<xsl:sort select="fs:Klokkeslett"/>
				<xsl:for-each select="fs:Klokkeslett">
					<xsl:variable name="tempKlokke">
						<xsl:call-template name="skrivUtTime"><xsl:with-param name="oppgittTid" select="."/></xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="normalize-space($tempKlokke)"/> <!-- Fjerner whitespace foran og bak -->
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="unionUnikKlokke"> <!-- Union av klokkeslett etter at duplikat er fjernet -->
			<xsl:call-template name="unikeKlokkerKalkulator">
				<xsl:with-param name="streng" select="$unionKlokke"/>
			</xsl:call-template>
		</xsl:variable>
				
		<xsl:variable name="kolonner">
			<xsl:choose>
				<xsl:when test="string-length($unionUnikOmrade) &gt; 0">
					<xsl:value-of select="string-length($unionUnikOmrade)+1"/>
				</xsl:when>
				<xsl:when test="string-length($unionUnikKlokke) &gt; 0">
					<xsl:value-of select="string-length($unionUnikKlokke) div 8+1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(.//fs:DoseFastTidspunkt)+1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$teller &lt; $kolonner">
			<td width="25%">
				<xsl:choose>
					<xsl:when test="$allFyll"><xsl:value-of select="$fyll"/></xsl:when>
					<xsl:when test=".//fs:FasteUkedager and .//fs:Tidsomrade">
						<xsl:choose>
							<xsl:when test="fs:DoseFastTidspunkt[.//fs:FasteUkedager/@V = $ukedag and fs:Tidsomrade and fs:Tidsomrade/@V = substring($unionUnikOmrade, $teller, 1)]">
								<xsl:for-each select="fs:DoseFastTidspunkt[.//fs:FasteUkedager/@V = $ukedag and fs:Tidsomrade and fs:Tidsomrade/@V = substring($unionUnikOmrade, $teller, 1)]">
									<xsl:value-of select="fs:Mengde/@V"/>&#160;
									<xsl:if test="fs:GisEksakt='true'">Eksakt&#160;tidspunkt</xsl:if>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test=".//fs:FasteUkedager and .//fs:Klokkeslett">
						<xsl:choose>
							<xsl:when test="fs:DoseFastTidspunkt[.//fs:FasteUkedager/@V = $ukedag and fs:Klokkeslett and substring(fs:Klokkeslett,1,5) = substring($unionUnikKlokke,($teller*8)-4,5)]">
								<xsl:for-each select="fs:DoseFastTidspunkt[.//fs:FasteUkedager/@V = $ukedag and fs:Klokkeslett and substring(fs:Klokkeslett,1,5) = substring($unionUnikKlokke,($teller*8)-4,5)]">
									<xsl:value-of select="fs:Mengde/@V"/>&#160;
									<xsl:if test="fs:GisEksakt='true'">Eksakt&#160;tidspunkt</xsl:if>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="fs:DoseFastTidspunkt">
							<xsl:sort select="fs:Tidsomrade/@V"/>
							<xsl:if test="position()=$teller">
								<xsl:value-of select="fs:Mengde/@V"/>&#160;
								<xsl:if test="fs:GisEksakt='true'">Eksakt&#160;tidspunkt</xsl:if>
							</xsl:if>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<xsl:call-template name="fyllDager">
				<xsl:with-param name="ukedag" select="$ukedag"/>
				<xsl:with-param name="teller" select="$teller + 1"/>
				<xsl:with-param name="fyll" select="$fyll"/>
				<xsl:with-param name="allFyll" select="$allFyll"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!-- Rekursiv funksjon til hjelp for å finne unike tidsområder -->
	<xsl:template name="unikeOmraderKalkulator">
		<xsl:param name="streng"/>
		<xsl:if test="string-length($streng) = 1"> <!-- Legger alltid til siste tidsområde -->
				<xsl:value-of select="$streng"/>
		</xsl:if>
		<xsl:if test="string-length($streng) &gt; 1">
			<xsl:if test="substring($streng,1,1) != substring($streng,2,1)"> <!-- Legger til tidsområdet i mengden kun hvis den er unik (forskjellig fra neste tidsområde) -->
				<xsl:value-of select="substring($streng,1,1)"/>
			</xsl:if>
			<xsl:call-template name="unikeOmraderKalkulator"> <!-- Rekursivt kall med resten av strengen som parameter -->
				<xsl:with-param name="streng" select="substring($streng,2)"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- Rekursiv funksjon som skrive ut kolonne-header for de unike og sorterte tidsområdene -->
	<xsl:template name="fyllOmraderHeader">
		<xsl:param name="streng"/>
		<xsl:if test="string-length($streng) &gt; 0">
			<th width="25%">
				<xsl:call-template name="k-8325">
					<xsl:with-param name="tidsOmrade" select="substring($streng,1,1)"/>
				</xsl:call-template>
			</th>
			<xsl:call-template name="fyllOmraderHeader">
				<xsl:with-param name="streng" select="substring($streng,2)"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- Rekursiv funksjon til hjelp for å finne unike klokkeslett -->
	<xsl:template name="unikeKlokkerKalkulator">
		<xsl:param name="streng"/>
		<xsl:if test="string-length($streng) = 8"> <!-- Legger alltid til siste klokkeslett. Ett klokkeslett er 8 tegn langt, f.eks. 'kl.10:00' -->
				<xsl:value-of select="$streng"/>
		</xsl:if>
		<xsl:if test="string-length($streng) &gt; 8">
			<xsl:if test="substring($streng,1,8) != substring($streng,9,8)"> <!-- Legger til tidsområdet i mengden kun hvis den er unik (forskjellig fra neste tidsområde) -->
				<xsl:value-of select="substring($streng,1,8)"/>
			</xsl:if>
			<xsl:call-template name="unikeKlokkerKalkulator">
				<xsl:with-param name="streng" select="substring($streng,9)"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- Rekursiv funksjon som skrive ut kolonne-header for de unike og sorterte klokkeslettene -->
	<xsl:template name="fyllKlokkeHeader">
		<xsl:param name="streng"/>
		<xsl:if test="string-length($streng) &gt; 0">
			<th width="25%">
				<xsl:value-of select="substring($streng,1,8)"/> <!-- Ett klokkeslett er 8 tegn langt, f.eks. 'kl.10:00' -->
			</th>
			<xsl:call-template name="fyllKlokkeHeader">
				<xsl:with-param name="streng" select="substring($streng,9)"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- Rekursiv funksjon til hjelp for å finne unike faste dager -->
	<xsl:template name="unikeFasteDagerKalkulator">
		<xsl:param name="streng"/>
		<xsl:if test="string-length($streng) = 1"> <!-- Legger alltid til siste faste dag -->
			<xsl:call-template name="k-9082">
				<xsl:with-param name="ukedag" select="$streng"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="string-length($streng) &gt; 1">
			<xsl:if test="substring($streng,1,1) != substring($streng,2,1)"> <!-- Legger til faste dager i mengden kun hvis den er unik (forskjellig fra neste tidsområde) -->
				<xsl:call-template name="k-9082">
					<xsl:with-param name="ukedag" select="substring($streng,1,1)"/>
				</xsl:call-template>,
			</xsl:if>
			<xsl:call-template name="unikeFasteDagerKalkulator"> <!-- Rekursivt kall med resten av strengen som parameter -->
				<xsl:with-param name="streng" select="substring($streng,2)"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- Kodeverk -->
	<xsl:template name="k-9082">
		<xsl:param name="ukedag"/>
		<xsl:choose>
			<xsl:when test="$ukedag='1'">Mandag</xsl:when>
			<xsl:when test="$ukedag='2'">Tirsdag</xsl:when>
			<xsl:when test="$ukedag='3'">Onsdag</xsl:when>
			<xsl:when test="$ukedag='4'">Torsdag</xsl:when>
			<xsl:when test="$ukedag='5'">Fredag</xsl:when>
			<xsl:when test="$ukedag='6'">Lørdag</xsl:when>
			<xsl:when test="$ukedag='7'">Søndag</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="k-8325">
		<xsl:param name="tidsOmrade"/>
		<xsl:choose>
			<xsl:when test="$tidsOmrade='1'">Morgen</xsl:when>
			<xsl:when test="$tidsOmrade='2'">Formiddag</xsl:when>
			<xsl:when test="$tidsOmrade='3'">Midt på dagen</xsl:when>
			<xsl:when test="$tidsOmrade='4'">Ettermiddag</xsl:when>
			<xsl:when test="$tidsOmrade='5'">Kveld</xsl:when>
			<xsl:when test="$tidsOmrade='6'">Natt</xsl:when>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
