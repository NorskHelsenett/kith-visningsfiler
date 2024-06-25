<?xml version="1.0" encoding="UTF-8"?>

<!-- Visningsfil for eReseptmeldingen: M2 Individuell søknad om refusjon til HELFO
	- Visningen håndterer vedlegg av en eller flere M12 Søknadssvar - Individuell søknad om refusjon til HELFO-->
<!-- Siste endring:
	- 09.08.22: v3.3.0: Semantisk HTML
	- 04.06.21: v3.2.3: La til xsl:output for å definere at output formatet skal være html
	- 31.05.21: v3.2.2: Tillate MimeType (vedlegg) med store bokstaver
	- 13.04.18: v3.2.1: Fikset bug hvor elementet Oppdatert ikke ble vist riktig. Endringer i noen overskrifter og diagnose-kodeverk. 
	- 16.02.18: v3.2.0: Tilpasset visningsfil for ny versjon av M2 og M12.
	- 09.05.17: v3.1.2: Rettet formell test på tekst mot number
	- 27.03.17: v3.1.1: Ny parameter for "visningStil". Ny stil "Smooth".
	- 25.10.16: v3.1.0: La til visningsversjonnr
	- 24.09.15: Oppdatert til siste versjon av 2.5 datert 2015-05-26. Felles kodeverksfil innført.
	- 31.10.13: Oppdatert til å kunne håndtere Forskrivning-2013-10-08
	- 13.08.13: Versjon for eResept v2.5
	- 11.02.11: Første versjon -->
	
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:m2="http://www.ehelse.no/xmlstds/eresept/m2/2017-12-01" 
	xmlns:m12="http://www.ehelse.no/xmlstds/eresept/m12/2017-12-01" 
	xmlns:base="http://www.kith.no/xmlstds/base64container" 
	exclude-result-prefixes="mh fk1 m2 m12 base">

	<xsl:import href="../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../felleskomponenter/base64decoder.xsl"/>
	<xsl:import href="../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Vedlegg i denne sammenhengen er en eller flere m12-meldinger -->
	<xsl:param name="vedlegg"/>

	<xsl:variable name="antall-legemidler" select="count(//m2:OmsoktLegemiddel)"/>
	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m2-2.5 - v3.3.0'"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>Individuell søknad om refusjon til HELFO</title>
				<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
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
	<xsl:template name="Innhold" match="m2:SoknadHelfo">
		<main class="{$stil}">
			<xsl:for-each select="//m2:SoknadHelfo">
				<h1>Individuell søknad om refusjon til HELFO</h1>
				<xsl:choose>
					<xsl:when test="$antall-legemidler=1">
						<h2>Omsøkt legemiddel</h2>
					</xsl:when>
					<xsl:when test="$antall-legemidler &gt; 1">
						<h2>Omsøkte legemidler</h2>
					</xsl:when>
				</xsl:choose>
				<xsl:for-each select="//m2:OmsoktLegemiddel">
					<xsl:apply-templates select="."/>
				</xsl:for-each>
				<xsl:for-each select="//m2:SoknadNaringsmiddel">
					<xsl:apply-templates select="."/>
				</xsl:for-each>
				<xsl:if test="//m2:BehRegime">
					<h2>Andre legemidler i behandlingsregimet</h2>
					<table>
						<tbody>
							<xsl:for-each select="//m2:BehRegime">
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</tbody>
					</table>
				</xsl:if>
				<xsl:if test="//m2:TidligereBehandling">
					<xsl:if test="//m2:SoknadNaringsmiddel">
						<h2>Tidligere brukte næringsmidler</h2>
					</xsl:if>
					<xsl:if test="//m2:OmsoktLegemiddel">
						<h2>Tidligere brukte legemidler</h2>
					</xsl:if>
					<table>
						<tbody>
							<xsl:for-each select="//m2:TidligereBehandling">
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</tbody>
					</table>
				</xsl:if>
				<table>
					<tbody>
						<tr>
							<td width="50%" style="border-style:none">
								<h2>Diagnoser</h2>
								<table>
									<tbody>
										<xsl:for-each select="m2:Diagnose">
											<tr>
												<td>
													<xsl:choose>
														<xsl:when test="contains(@S, '7110')">
															<xsl:call-template name="k-dummy-V"/>
														</xsl:when>
														<xsl:when test="contains(@S, '7170')">
															<xsl:call-template name="k-dummy-V"/>
														</xsl:when>
														<xsl:when test="contains(@S, '7434')">
															<xsl:call-template name="k-dummy-V"/>
														</xsl:when>
														<xsl:when test="contains(@S, '7435')">
															<xsl:call-template name="k-dummy-V"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:call-template name="k-dummy"/>
														</xsl:otherwise>
													</xsl:choose>
												</td>
											</tr>
										</xsl:for-each>
										<xsl:for-each select="m2:RelatertDiagnose">
											<tr>
												<td>
													<xsl:choose>
														<xsl:when test="contains(@S, '7110')">
															<xsl:call-template name="k-dummy"/>
														</xsl:when>
														<xsl:when test="contains(@S, '7170')">
															<xsl:call-template name="k-dummy"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:call-template name="k-dummy"/>
														</xsl:otherwise>
													</xsl:choose>
												</td>
											</tr>
										</xsl:for-each>
									</tbody>
								</table>
							</td>
							<td width="50%" valign="top" style="border-style:none">
								<h2>Refusjon</h2>
								<table>
									<tbody>
										<xsl:for-each select="m2:RefHjemmel">
											<tr>
												<td>
													<xsl:choose>
														<xsl:when test="contains(@S, '7427')">
															<xsl:call-template name="k-7427"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:call-template name="k-dummy"/>
														</xsl:otherwise>
													</xsl:choose>
												</td>
											</tr>
										</xsl:for-each>
									</tbody>
								</table>
							</td>
						</tr>
					</tbody>
				</table>
				<h2>Relevant informasjon</h2>
				<table>
					<tbody>
						<xsl:if test="m2:Begrunnelse or m2:Merknad">
							<tr>
								<xsl:if test="m2:Begrunnelse">
									<th width="25%">Begrunnelse</th>
								</xsl:if>
								<xsl:if test="m2:Merknad">
									<th width="25%">Merknad</th>
								</xsl:if>
							</tr>
							<tr>
								<xsl:if test="m2:Begrunnelse">
									<td width="25%">
										<xsl:value-of select="m2:Begrunnelse"/>
									</td>
								</xsl:if>
								<xsl:if test="m2:Merknad">
									<td width="25%">
										<xsl:value-of select="m2:Merknad"/>
									</td>
								</xsl:if>
							</tr>
						</xsl:if>
						<xsl:if test="m2:Soknad3 or m2:Vedlegg">
							<tr>
								<xsl:if test="m2:Soknad3/m2:AlvorligSykdom">
									<th width="25%">Alvorlig sykdom</th>
								</xsl:if>
								<xsl:if test="m2:Soknad3/m2:Prioriteringskriterier">
									<th width="25%">Prioriteringskriterier</th>
								</xsl:if>
								<xsl:if test="m2:Vedlegg">
									<th width="25%">Referanser til vedlegg</th>
								</xsl:if>
							</tr>
							<tr>
								<xsl:if test="m2:Soknad3/m2:AlvorligSykdom">
									<td width="25%">
										<xsl:for-each select="m2:Soknad3/m2:AlvorligSykdom">
											<xsl:choose>
												<xsl:when test="contains(@S, '7531')">
													<xsl:call-template name="k-7531"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="k-dummy"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
									</td>
								</xsl:if>
								<xsl:if test="m2:Soknad3/m2:Prioriteringskriterier">
									<td width="25%">
										<xsl:value-of select="m2:Soknad3/m2:Prioriteringskriterier"/>
									</td>
								</xsl:if>
								<xsl:if test="m2:Vedlegg">
									<td width="25%">
										<xsl:for-each select="m2:Vedlegg">
											<xsl:if test="position() != 1"><br/></xsl:if>
											<xsl:value-of select="."/>
										</xsl:for-each>
									</td>
								</xsl:if>
							</tr>
						</xsl:if>
						<xsl:if test="m2:KroniskSykdom or m2:LangvarigBehandling or m2:UtenforInstitusjon">
							<tr>
								<xsl:if test="m2:LangvarigBehandling">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="m2:LangvarigBehandling/@V = '1'">
												<input type="checkbox" disabled="disabled" checked="checked">Langvarig behandling</input>
											</xsl:when>
											<xsl:otherwise>
												<input type="checkbox" disabled="disabled">Langvarig behandling</input>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:if>
								<xsl:if test="m2:UtenforInstitusjon">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="m2:UtenforInstitusjon/@V = '1'">
												<input type="checkbox" disabled="disabled" checked="checked">Bruk utenfor institusjon</input>
											</xsl:when>
											<xsl:otherwise>
												<input type="checkbox" disabled="disabled">Bruk utenfor institusjon</input>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:if>
							</tr>
						</xsl:if>
						<xsl:if test="m2:Forstegangs">
							<tr>
								<xsl:if test="m2:Forstegangs">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="m2:Forstegangs/@V = '1'">
												<input type="checkbox" disabled="disabled" checked="checked">Førstegangssøknad</input>
											</xsl:when>
											<xsl:otherwise>
												<input type="checkbox" disabled="disabled">Førstegangssøknad</input>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:if>
							</tr>
						</xsl:if>
						<xsl:if test="m2:Oppdatert">
							<tr>
								<xsl:if test="m2:Oppdatert">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="m2:Oppdatert = 'true'">
												<input type="checkbox" disabled="disabled" checked="checked">Oppdatering av tidligere søknad</input>
											</xsl:when>
											<xsl:otherwise>
												<input type="checkbox" disabled="disabled">Oppdatering av tidligere søknad</input>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:if>
							</tr>
						</xsl:if>
						<xsl:if test="//m2:Yrkesskade">
							<tr>
								<xsl:if test="//m2:Yrkesskade/m2:Vedtak">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="//m2:Yrkesskade/m2:Vedtak/@V = '1'">
												<input type="checkbox" disabled="disabled" checked="checked">Har&#160;vedtak&#160;om&#160;yrkesskade</input>
											</xsl:when>
											<xsl:otherwise>
												<input type="checkbox" disabled="disabled">Har&#160;vedtak&#160;om&#160;yrkesskade</input>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:if>
								<xsl:if test="//m2:Yrkesskade/m2:Arsak">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="//m2:Yrkesskade/m2:Arsak/@V = '1'">
												<input type="checkbox" disabled="disabled" checked="checked">Yrkesskade&#160;årsak&#160;til&#160;behandlingsbehovet</input>
											</xsl:when>
											<xsl:otherwise>
												<input type="checkbox" disabled="disabled">Yrkesskade&#160;årsak&#160;til&#160;behandlingsbehovet</input>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:if>
							</tr>
						</xsl:if>
					</tbody>
				</table>
				<xsl:if test="m2:Instituert">
					<h2>Instituert av</h2>
					<table>
						<tbody>
							<xsl:if test="m2:Instituert/m2:Organisasjon">
								<tr>
									<xsl:if test="m2:Instituert/m2:Organisasjon/m2:HerId"><th width="25%">HER-id</th></xsl:if>
									<xsl:if test="m2:Instituert/m2:Organisasjon/m2:Inst"><th width="25%">Inst</th></xsl:if>
									<xsl:if test="m2:Instituert/m2:Organisasjon/m2:Dept"><th width="25%">Dept</th></xsl:if>
									<xsl:if test="m2:Instituert/m2:Organisasjon/m2:InstitusjonsID"><th width="25%">Institusjonsid</th></xsl:if>	
								</tr>
								<tr>
									<xsl:if test="m2:Instituert/m2:Organisasjon/m2:HerId">
										<td width="25%">
										<xsl:value-of select="m2:Instituert/m2:Organisasjon/m2:HerId/fk1:Id"/>
										</td>
									</xsl:if>
									<xsl:if test="m2:Instituert/m2:Organisasjon/m2:Inst"><td width="25%"><xsl:value-of select="m2:Instituert/m2:Organisasjon/m2:Inst"/></td></xsl:if>
									<xsl:if test="m2:Instituert/m2:Organisasjon/m2:Dept"><td width="25%"><xsl:value-of select="m2:Instituert/m2:Organisasjon/m2:Dept"/></td></xsl:if>
									<xsl:if test="m2:Instituert/m2:Organisasjon/m2:InstitusjonsID">
										<td width="25%">
											<xsl:choose>
												<xsl:when test="m2:Instituert/m2:Organisasjon/m2:InstitusjonsID/@DN">
													<xsl:value-of select="m2:Instituert/m2:Organisasjon/m2:InstitusjonsID/@DN"/>
												</xsl:when>
												<xsl:otherwise>
													<b>Kodet: </b><xsl:value-of select="m2:Instituert/m2:Organisasjon/m2:InstitusjonsID/@V"/>
												</xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:if>
								</tr>
							</xsl:if>
							<xsl:if test="m2:Instituert/m2:Helseperson">
								<tr>
									<xsl:if test="m2:Instituert/m2:Helseperson/m2:HprId"><th width="25%">HPR-id</th></xsl:if>
									<xsl:if test="m2:Instituert/m2:Helseperson/m2:Fornavn or m2:Instituert/m2:Helseperson/m2:Etternavn"><th width="25%">Navn</th></xsl:if>
									<xsl:if test="m2:Instituert/m2:Helseperson/m2:Spesialitet"><th width="25%">Spesialitet</th></xsl:if>
								</tr>
								<tr>
									<xsl:if test="m2:Instituert/m2:Helseperson/m2:HprId"><td width="25%"><xsl:value-of select="m2:Instituert/m2:Helseperson/m2:HprId/fk1:Id"/></td></xsl:if>
									<xsl:if test="m2:Instituert/m2:Helseperson/m2:Fornavn or m2:Instituert/m2:Helseperson/m2:Etternavn">
										<xsl:choose>
											<xsl:when test="m2:Instituert/m2:Helseperson/m2:Fornavn and m2:Instituert/m2:Helseperson/m2:Etternavn">
												<td width="25%"><xsl:value-of select="m2:Instituert/m2:Helseperson/m2:Fornavn"/>&#160;<xsl:value-of select="m2:Instituert/m2:Helseperson/m2:Etternavn"/></td>
											</xsl:when>
											<xsl:otherwise>
												<xsl:if test="m2:Instituert/m2:Helseperson/m2:Fornavn">
													<td width="25%"><xsl:value-of select="m2:Instituert/m2:Helseperson/m2:Fornavn"/></td>
												</xsl:if>
												<xsl:if test="m2:Instituert/m2:Helseperson/m2:Etternavn">
													<td width="25%"><xsl:value-of select="m2:Instituert/m2:Helseperson/m2:Etternavn"/></td>
												</xsl:if>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:if>
									<xsl:if test="m2:Helseperson/m2:Spesialitet">
										<td width="25%">
											<xsl:choose>
												<xsl:when test="m2:Helseperson/m2:Spesialitet/@DN"><xsl:value-of select="m2:Helseperson/m2:Spesialitet/@DN"/></xsl:when>
												<xsl:otherwise><b>Kodet: </b><xsl:value-of select="m2:Helseperson/m2:Spesialitet/@V"/></xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:if>
								</tr>
							</xsl:if>
						</tbody>
					</table>
				</xsl:if>
				<xsl:if test="string-length($vedlegg) != 0">
					<xsl:apply-templates select="$vedlegg//m12:Soknadssvar"/>
				</xsl:if>
			</xsl:for-each>
			<xsl:apply-templates select="//m12:Soknadssvar"/>
			<xsl:for-each select="//mh:RefDoc[mh:MsgType/@V='A' and not(.//m12:Soknadssvar)]">
				<xsl:if test="position()=1">
					<h2>Vedlegg</h2>
				</xsl:if>			
				<table>
					<tbody>
						<xsl:if test="mh:Content or mh:FileReference">
							<xsl:choose>
								<xsl:when test="contains(mh:MimeType,'plain') or contains(mh:MimeType,'text') or contains(mh:MimeType,'xml')">
									<tr>
										<th>Tekst</th>
										<xsl:choose>
											<xsl:when test="mh:FileReference">
												<td>
													<a>
														<xsl:attribute name="href"><xsl:value-of select="mh:FileReference"/></xsl:attribute>Filreferanse
													</a>
												</td>
											</xsl:when>
											<xsl:when test="mh:Content">
												<td>
													<xsl:choose>
														<xsl:when test="mh:Content/base:Base64Container">
															<xsl:call-template name="convertBase64ToAscii">
																<xsl:with-param name="base64String" select="mh:Content/base:Base64Container"/>
															</xsl:call-template>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="mh:Content"/>
														</xsl:otherwise>
													</xsl:choose>
												</td>
											</xsl:when>
										</xsl:choose>
									</tr>
								</xsl:when>
								<xsl:when test="contains(mh:MimeType,'image')">
									<tr>
										<th>Bilde</th>
										<xsl:choose>
											<xsl:when test="mh:FileReference">
												<td>
													<img>
														<xsl:attribute name="src"><xsl:value-of select="mh:FileReference"/></xsl:attribute>
														<xsl:attribute name="alt">Bilde fra ekstern URL</xsl:attribute>
													</img>
												</td>
											</xsl:when>
											<xsl:when test="mh:Content">
												<td>
													<xsl:choose>
														<xsl:when test="mh:Content/base:Base64Container">
															<img>
																<xsl:attribute name="src"><xsl:value-of select="concat('data:',mh:MimeType,';base64,',mh:Content/base:Base64Container)"/></xsl:attribute>
																<xsl:attribute name="alt">Bilde vedlagt som base64-kode</xsl:attribute>
															</img>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="mh:Content"/>
														</xsl:otherwise>
													</xsl:choose>
												</td>
											</xsl:when>
										</xsl:choose>
									</tr>
								</xsl:when>
								<xsl:when test="contains(mh:MimeType,'pdf') or contains(mh:MimeType,'PDF')">
									<tr>
										<th>PDF</th>
										<xsl:choose>
											<xsl:when test="mh:FileReference">
												<td>
													<object>
														<xsl:attribute name="data"><xsl:value-of select="concat(mh:FileReference,'&#35;view&#61;FitH&#38;toolbar&#61;1')"/></xsl:attribute>
														<xsl:attribute name="type">application/pdf</xsl:attribute>
														<xsl:attribute name="width">100%</xsl:attribute>
														<xsl:attribute name="height">500px</xsl:attribute>
													</object>
												</td>
											</xsl:when>
											<xsl:when test="mh:Content">
												<td>
													<xsl:choose>
														<xsl:when test="mh:Content/base:Base64Container">
															<object>
																<xsl:attribute name="data"><xsl:value-of select="concat('data:application/pdf;base64,',mh:Content/base:Base64Container)"/></xsl:attribute>
																<xsl:attribute name="type">application/pdf</xsl:attribute>
																<xsl:attribute name="width">100%</xsl:attribute>
																<xsl:attribute name="height">500px</xsl:attribute>
															</object>
															<p> <!-- Denne paragrafen blir aktivert når pdf-visningen feiler - f.eks. med InternetExplorer -->
																<span class="strong">Visning av vedlagte pdf-fil feilet.</span><br/>
																Vanligste årsak er bruk av Internet Explorer, eller manglende plug-in.
															</p>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="mh:Content"/>
														</xsl:otherwise>
													</xsl:choose>
												</td>
											</xsl:when>
										</xsl:choose>
									</tr>
								</xsl:when>
								<xsl:otherwise>
									<tr>
										<th>Uhåndterbar mimetype</th>
											<!--<xsl:choose>
												<xsl:when test="mh:Content">
													<xsl:value-of select="mh:Content"/>
												</xsl:when>
												<xsl:when test="mh:FileReference">
													<xsl:value-of select="mh:FileReference"/>
												</xsl:when>
											</xsl:choose> -->
									</tr>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="mh:MsgType or mh:Id or mh:IssueDate or mh:MimeType or mh:Compression">
							<tr>
								<th>Metadata</th>
								<td colspan="3">
									<xsl:if test="mh:MsgType">
										<span class="strong">Meldingstype&#160;</span><xsl:value-of select="mh:MsgType/@DN"/>&#160;
									</xsl:if>
									<xsl:if test="mh:Id">
										<span class="strong">Id:&#160;</span><xsl:value-of select="mh:Id"/>&#160;
									</xsl:if>
									<xsl:if test="mh:IssueDate">
										<span class="strong">Utstedt-dato:&#160;</span><xsl:call-template name="skrivUtDateTime"><xsl:with-param name="oppgittTid" select="mh:IssueDate/@V"/></xsl:call-template>&#160;
									</xsl:if>
									<xsl:if test="mh:MimeType">
										<span class="strong">Mimetype:&#160;</span><xsl:value-of select="mh:MimeType"/>&#160;
									</xsl:if>
									<xsl:if test="mh:Compression">
										<span class="strong">Komprimering:&#160;</span><xsl:value-of select="mh:Compression/@DN"/>&#160;
									</xsl:if>
									<xsl:if test="mh:Description">
										<span class="strong">Beskrivelse:&#160;</span>
										<xsl:call-template name="line-breaks">
											<xsl:with-param name="text" select="mh:Description"/>
										</xsl:call-template>&#160;
									</xsl:if>
								</td>
							</tr>
						</xsl:if>
					</tbody>
				</table>
			</xsl:for-each>
		</main>
	</xsl:template>
	<xsl:template match="m2:OmsoktLegemiddel">
		<xsl:variable name="refId">
			<xsl:choose>
				<xsl:when test="$antall-legemidler=1">
					<xsl:value-of select="/.//mh:MsgId"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="m2:Uuid"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<table>
			<tbody>
				<xsl:if test="m2:ForskrivningB64 or ../m2:IngenTidlBehandling or string-length($vedlegg) != 0 or /m2:ReseptklasseAB">
					<xsl:variable name="konvertertBase64">
						<xsl:call-template name="convertBase64ToAscii">
							<xsl:with-param name="base64String" select="m2:ForskrivningB64"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="m2:ForskrivningB64 and contains($konvertertBase64, 'Legemiddelblanding')">
							<xsl:if test="not(preceding-sibling::m2:OmsoktLegemiddel)">
								<tr>
									<xsl:call-template name="fellesLegemiddelTopp">
										<xsl:with-param name="konvertertBase64" select="$konvertertBase64"/>
									</xsl:call-template>
									<xsl:call-template name="fellesLegemiddelAvsluttningTopp"/>
								</tr>
							</xsl:if>
							<tr>
								<xsl:call-template name="fellesLegemiddelBunn">
									<xsl:with-param name="konvertertBase64" select="$konvertertBase64"/>
								</xsl:call-template>
								<xsl:call-template name="fellesLegemiddelAvsluttningBunn">
									<xsl:with-param name="refId" select="$refId"/>
								</xsl:call-template>
							</tr>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="not(preceding-sibling::m2:OmsoktLegemiddel)">
								<tr>
									<xsl:call-template name="fellesLegemiddelKortTopp">
										<xsl:with-param name="konvertertBase64" select="$konvertertBase64"/>
									</xsl:call-template>
									<xsl:call-template name="fellesLegemiddelAvsluttningTopp"/>
								</tr>
							</xsl:if>
							<tr>
								<xsl:call-template name="fellesLegemiddelKortBunn">
									<xsl:with-param name="konvertertBase64" select="$konvertertBase64"/>
								</xsl:call-template>
								<xsl:call-template name="fellesLegemiddelAvsluttningBunn">
									<xsl:with-param name="refId" select="$refId"/>
								</xsl:call-template>
							</tr>
						</xsl:otherwise>
					</xsl:choose>
					<!-- FORTSETT HER OG IMPLEMENTER RESEPTKLASSEAB -->
					<xsl:if test="m2:ReseptklasseAB">
						<tr>
							<th>Reseptklasse A eller B</th>
						</tr>
						<xsl:if test="m2:ReseptklasseAB/m2:HoyesteDogndose/@V">
							<tr>
								<td>Høyeste døgndose &#160;
									<xsl:value-of select="m2:ReseptklasseAB/m2:HoyesteDogndose/@V"/>&#160;<xsl:value-of select="m2:ReseptklasseAB/m2:HoyesteDogndose/@U"/>
								</td>
							</tr>
						</xsl:if>
						<xsl:if test="m2:ReseptklasseAB/m2:Behandlingsplan">
							<tr>
								<td width="25%">
									<xsl:choose>
										<xsl:when test="m2:ReseptklasseAB/m2:Behandlingsplan/@V = '1'">
											<input type="checkbox" disabled="disabled" checked="checked">Behandlingsplan</input>
										</xsl:when>
										<xsl:otherwise>
											<input type="checkbox" disabled="disabled">Behandlingsplan</input>
										</xsl:otherwise>
									</xsl:choose>
								</td>	
							</tr>	
						</xsl:if>
						<xsl:if test="m2:ReseptklasseAB/m2:AvhengihetsfareVurdert">
							<tr>
								<td width="25%">
									<xsl:choose>
										<xsl:when test="m2:ReseptklasseAB/m2:AvhengihetsfareVurdert/@V = '1'">
											<input type="checkbox" disabled="disabled" checked="checked">Avhengighetsfare vurdert</input>
										</xsl:when>
										<xsl:otherwise>
											<input type="checkbox" disabled="disabled">Avhengighetsfare vurdert</input>
										</xsl:otherwise>
									</xsl:choose>
								</td>	
							</tr>	
						</xsl:if>
						<xsl:if test="m2:ReseptklasseAB/m2:Smerteanalyse">
							<tr>
								<td width="25%">
									<xsl:choose>
										<xsl:when test="m2:ReseptklasseAB/m2:Smerteanalyse/@V = '1'">
											<input type="checkbox" disabled="disabled" checked="checked">Smerteanalyse foretatt</input>
										</xsl:when>
										<xsl:otherwise>
											<input type="checkbox" disabled="disabled">Smerteanalyse foretatt</input>
										</xsl:otherwise>
									</xsl:choose>
								</td>	
							</tr>	
						</xsl:if>
						<!-- Test på om gyldig forskriver er oppgitt -->
						<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver">
							<tr>
								<td><b>Gyldig forskriver</b></td>
							</tr>
							<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon">
								<tr>
									<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:HerId"><th width="25%">HER-id</th></xsl:if>
									<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:Inst"><th width="25%">Inst</th></xsl:if>
									<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:Dept"><th width="25%">Dept</th></xsl:if>
									<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:InstitusjonsID"><td width="25%">Institusjonsid</td></xsl:if>	
								</tr>
								<tr>
									<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:HerId"><td width="25%"><xsl:value-of select="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:HerId/fk1:Id"/></td></xsl:if>
									<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:Inst"><td width="25%"><xsl:value-of select="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:Inst"/></td></xsl:if>
									<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:Dept"><td width="25%"><xsl:value-of select="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:Dept"/></td></xsl:if>
									<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:InstitusjonsID">
										<td width="25%">
											<xsl:choose>
												<xsl:when test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:InstitusjonsID/@DN">
													<xsl:value-of select="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:InstitusjonsID/@DN"/>
												</xsl:when>
												<xsl:otherwise>
													<b>Kodet: </b><xsl:value-of select="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Organisasjon/m2:InstitusjonsID/@V"/>
												</xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:if>
								</tr>
							</xsl:if>
							<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson">
								<tr>
									<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:HprId"><th width="25%">HPR-id</th></xsl:if>
									<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:Fornavn or m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:Etternavn"><th width="25%">Navn</th></xsl:if>
									<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:Spesialitet"><th width="25%">Spesialitet</th></xsl:if>
								</tr>
								<tr>
									<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:HprId"><td width="25%"><xsl:value-of select="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:HprId/fk1:Id"/></td></xsl:if>
									<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:Fornavn or m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:Etternavn">
										<xsl:choose>
											<xsl:when test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:Fornavn and m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:Etternavn">
												<td width="25%"><xsl:value-of select="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:Fornavn"/>&#160;<xsl:value-of select="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:Etternavn"/></td>
											</xsl:when>
											<xsl:otherwise>
												<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:Fornavn">
													<td width="25%"><xsl:value-of select="m2:Instituert/m2:Helseperson/m2:Fornavn"/></td>
												</xsl:if>
												<xsl:if test="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:Etternavn">
													<td width="25%"><xsl:value-of select="m2:ReseptklasseAB/m2:GyldigForskriver/m2:Helseperson/m2:Etternavn"/></td>
												</xsl:if>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:if>
									<xsl:if test="m2:Helseperson/m2:Spesialitet">
										<td width="25%">
											<xsl:choose>
												<xsl:when test="m2:Helseperson/m2:Spesialitet/@DN"><xsl:value-of select="m2:Helseperson/m2:Spesialitet/@DN"/></xsl:when>
												<xsl:otherwise><b>Kodet: </b><xsl:value-of select="m2:Helseperson/m2:Spesialitet/@V"/></xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:if>
								</tr>
							</xsl:if>
						</xsl:if>
					</xsl:if>
				</xsl:if>
			</tbody>
		</table>
		<xsl:if test="not(following-sibling::m2:OmsoktLegemiddel)">
			<p/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="m2:BehRegime">
		<table>
			<tbody>
				<xsl:for-each select="m2:ForskrivningB64">
					<xsl:variable name="konvertertBase64">
						<xsl:call-template name="convertBase64ToAscii">
							<xsl:with-param name="base64String" select="."/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="contains($konvertertBase64, 'Legemiddelblanding')">
							<xsl:if test="position() = 1">
								<tr>
									<xsl:call-template name="fellesLegemiddelTopp">
										<xsl:with-param name="konvertertBase64" select="$konvertertBase64"/>
									</xsl:call-template>
								</tr>
							</xsl:if>
							<tr>
								<xsl:call-template name="fellesLegemiddelBunn">
									<xsl:with-param name="konvertertBase64" select="$konvertertBase64"/>
								</xsl:call-template>
							</tr>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="position() = 1">
								<tr>
									<xsl:call-template name="fellesLegemiddelKortTopp">
										<xsl:with-param name="konvertertBase64" select="$konvertertBase64"/>
									</xsl:call-template>
								</tr>
							</xsl:if>
							<tr>
								<xsl:call-template name="fellesLegemiddelKortBunn">
									<xsl:with-param name="konvertertBase64" select="$konvertertBase64"/>
								</xsl:call-template>
							</tr>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	<xsl:template match="m2:SoknadNaringsmiddel">
		<h2>Omsøkt næringsmiddel</h2>
		<xsl:variable name="refId" select="/.//mh:MsgId"/>
		<table>
			<tbody>
				<xsl:if test="m2:Produktgruppe/@DN or m2:Varenavn or string-length($vedlegg) != 0">
					<tr>
						<xsl:if test="m2:Produktgruppe/@DN">
							<th width="25%">Produktgruppe</th>
						</xsl:if>
						<xsl:if test="m2:Varenavn">
							<th width="25%">Varenavn</th>
						</xsl:if>
						<xsl:if test="string-length($vedlegg) != 0">
							<th width="25%">Søknadssvar</th>
						</xsl:if>
					</tr>
					<tr>
						<xsl:if test="m2:Produktgruppe/@DN">
							<td width="25%">
								<xsl:value-of select="m2:Produktgruppe/@DN"/>
							</td>
						</xsl:if>
						<xsl:if test="m2:Varenavn">
							<td width="25%">
								<xsl:value-of select="m2:Varenavn"/>
							</td>
						</xsl:if>
						<xsl:if test="string-length($vedlegg) != 0">
							<td width="25%">
								<xsl:choose>
									<xsl:when test="count($vedlegg//m12:Soknadssvar) != 0">
										<xsl:choose>
											<xsl:when test="count($vedlegg//m12:Soknadssvar[$refId = m12:RefSoknad]) != 0">
												<xsl:value-of select="$vedlegg//m12:Soknadssvar[$refId = m12:RefSoknad]/m12:Beslutning/@DN"/>
											</xsl:when>
											<xsl:otherwise>
											Mangler vedlagt søknadssvar med samsvarende referanse
										</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
									Mangler vedlagt søknadssvar
								</xsl:otherwise>
								</xsl:choose>
							</td>
						</xsl:if>
					</tr>
				</xsl:if>
				<xsl:if test="m2:KroniskSykdom">
					<tr>
						<th>Kronisk sykdom</th>
					</tr>
					<tr>
						<td width="25%">
							<xsl:choose>
								<xsl:when test="m2:KroniskSykdom/@V = '1'">
									<input type="checkbox" disabled="disabled" checked="checked">Kronisk sykdom</input>
								</xsl:when>
								<xsl:otherwise>
									<input type="checkbox" disabled="disabled">Kronisk sykdom</input>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
				</xsl:if>
				<xsl:if test="m2:Begrunnelse">
					<tr>
						<th width="25%">Begrunnelse</th>
					</tr>
					<tr>
						<td width="25%">
							<xsl:value-of select="m2:Begrunnelse/@DN"/>
						</td>
					</tr>
				</xsl:if>
				<xsl:if test="m2:Beskrivelse">
					<tr>
						<th width="25%">Beskrivelse</th>
					</tr>
					<tr>
						<td width="25%">
							<xsl:value-of select="m2:Beskrivelse"/>
						</td>
					</tr>
				</xsl:if>
			</tbody>
		</table>
		<p/>
	</xsl:template>
	<xsl:template match="m2:TidligereBehandling">
		<xsl:if test="m2:Varenavn or m2:Beskrivelse">
			<xsl:if test="not(preceding-sibling::m2:TidligereBehandling)">
				<tr>
					<xsl:if test="m2:Varenavn">
						<th width="25%">Varenavn</th>
					</xsl:if>
					<xsl:if test="m2:Beskrivelse">
						<th width="25%">Beskrivelse</th>
					</xsl:if>
				</tr>
			</xsl:if>
			<tr>
				<xsl:if test="m2:Varenavn">
					<td width="25%">
						<xsl:value-of select="m2:Varenavn"/>
					</td>
				</xsl:if>
				<xsl:if test="m2:Beskrivelse">
					<td width="25%">
						<xsl:value-of select="m2:Beskrivelse"/>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="m2:ForskrivningB64 or m2:MedisinskeHensyn">
			<xsl:variable name="konvertertBase64">
				<xsl:call-template name="convertBase64ToAscii">
					<xsl:with-param name="base64String" select="m2:ForskrivningB64"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="not(preceding-sibling::m2:TidligereBehandling)">
				<tr>
					<xsl:if test="m2:ForskrivningB64 and contains($konvertertBase64, 'NavnFormStyrke')">
						<th width="25%">NavnFormStyrke</th>
					</xsl:if>
					<xsl:if test="m2:MedisinskeHensyn/@DN">
						<th width="25%">Særlige grunner</th>
					</xsl:if>
				</tr>
			</xsl:if>
			<tr>
				<xsl:if test="m2:ForskrivningB64 and contains($konvertertBase64, 'NavnFormStyrke')">
					<td width="25%">
						<xsl:value-of select="substring-after(substring-before($konvertertBase64, '&lt;/NavnFormStyrke&gt;'),'&lt;NavnFormStyrke&gt;')"/>
					</td>
				</xsl:if>
				<xsl:if test="m2:MedisinskeHensyn/@DN">
					<td width="25%">
						<xsl:value-of select="m2:MedisinskeHensyn/@DN"/>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
	</xsl:template>
	<xsl:template match="m12:Soknadssvar">
		<h2>M12 - Søknadssvar</h2>
		<table>
			<tbody>
				<xsl:if test="m12:OmsoktVare or m12:Begrunnelse">
					<tr>
						<xsl:if test="m12:OmsoktVare">
							<th width="25%">Omsøkt vare</th>
						</xsl:if>
						<xsl:if test="m12:Begrunnelse">
							<th width="25%">Begrunnelse</th>
						</xsl:if>
					</tr>
					<tr>
						<xsl:if test="m12:OmsoktVare">
							<td width="25%">
								<xsl:value-of select="m12:OmsoktVare"/>
							</td>
						</xsl:if>
						<xsl:if test="m12:Begrunnelse">
							<td width="25%">
								<xsl:value-of select="m12:Begrunnelse"/>
							</td>
						</xsl:if>
					</tr>
				</xsl:if>
				<xsl:if test="m12:Beslutning or m12:Avslagsgrunn or m12:Vedtaksdato">
					<tr>
						<xsl:if test="m12:Beslutning">
							<th width="25%">Beslutning</th>
						</xsl:if>
						<xsl:if test="m12:Avslagsgrunn">
							<th width="25%">Avslagsgrunn</th>
						</xsl:if>
						<xsl:if test="m12:Vedtaksdato">
							<th width="25%">Vedtaksdato</th>
						</xsl:if>
					</tr>
					<tr>
						<xsl:if test="m12:Beslutning">
							<td width="25%">
								<xsl:for-each select="m12:Beslutning">
									<xsl:call-template name="k-7482"/>
								</xsl:for-each>
							</td>
						</xsl:if>
						<xsl:if test="m12:Avslagsgrunn">
							<td width="25%">
								<xsl:for-each select="m12:Avslagsgrunn">
									<xsl:if test="position() != 1"><br/></xsl:if>
									<xsl:call-template name="k-7481"/>
								</xsl:for-each>
							</td>
						</xsl:if>
						<xsl:if test="m12:Vedtaksdato">
							<td width="25%">
								<xsl:value-of select="m12:Vedtaksdato"/>
							</td>
						</xsl:if>
					</tr>
				</xsl:if>
				<xsl:for-each select="m12:VedtaketOmfatter">
					<tr>
						<td>
							<h2>Vedtaket omfatter</h2>
						</td>
					</tr>
					<xsl:if test="m12:Varenavn or m12:ProdGruppe or m12:DoseDognMaks">
						<tr>
							<xsl:if test="m12:Varenavn">
								<th width="25%">Varenavn</th>
							</xsl:if>
							<xsl:if test="m12:ProdGruppe">
								<th width="25%">Gruppe</th>
							</xsl:if>
							<xsl:if test="m12:DoseDognMaks">
								<th width="25%">Maks døgndose</th>
							</xsl:if>
						</tr>
						<tr>
							<xsl:if test="m12:Varenavn">
								<td width="25%">
									<xsl:value-of select="m12:Varenavn"/>
								</td>
							</xsl:if>
							<xsl:if test="m12:ProdGruppe">
								<td width="25%">
									<xsl:for-each select="m12:ProdGruppe">
										<xsl:if test="position() != 1"><br/></xsl:if>
										<xsl:choose>
											<xsl:when test="contains(@S, '7403')">
												<xsl:call-template name="k-7403"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="k-dummy"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</td>
							</xsl:if>
							<xsl:if test="m12:DoseDognMaks">
								<td width="25%">
									<xsl:value-of select="m12:DoseDognMaks/@V"/>&#160;<xsl:value-of select="m12:DoseDognMaks/@U"/>
								</td>
							</xsl:if>
						</tr>
					</xsl:if>
					<xsl:if test="m12:RefHjemmel or m12:RefKode or m12:GyldigTil">
						<tr>
							<xsl:if test="m12:RefHjemmel">
								<th width="25%">Refusjonshjemmel</th>
							</xsl:if>
							<xsl:if test="m12:RefKode">
								<th width="25%">Ref.kode</th>
							</xsl:if>
							<xsl:if test="m12:GyldigTil">
								<th width="25%">Gyldig til</th>
							</xsl:if>
						</tr>
						<tr>
							<xsl:if test="m12:RefHjemmel">
								<td width="25%">
									<xsl:for-each select="m12:RefHjemmel">
										<xsl:if test="position() != 1"><br/></xsl:if>
										<xsl:choose>
											<xsl:when test="contains(@S, '7427')">
												<xsl:call-template name="k-7427"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="k-dummy"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</td>
							</xsl:if>
							<xsl:if test="m12:RefKode">
								<td width="25%">
									<xsl:for-each select="m12:RefKode">
										<xsl:if test="position() != 1"><br/></xsl:if>
										<xsl:choose>
											<xsl:when test="contains(@S, '7434')">
												<xsl:call-template name="k-7434"/>
											</xsl:when>
											<xsl:when test="contains(@S, '7435')">
												<xsl:call-template name="k-7435"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="k-dummy"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</td>
							</xsl:if>
							<xsl:if test="m12:GyldigTil">
								<td width="25%">
									<xsl:value-of select="m12:GyldigTil"/>
								</td>
							</xsl:if>
						</tr>
					</xsl:if>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	<!-- Felles templates -->
	<xsl:template name="fellesLegemiddelTopp">
		<xsl:param name="konvertertBase64"/>
		<xsl:if test="string-length($konvertertBase64) != 0 and contains($konvertertBase64, 'Navn')">
			<th width="20%">Navn</th>
		</xsl:if>
		<xsl:if test="string-length($konvertertBase64) != 0 and contains($konvertertBase64, 'TilbOppl')">
			<th width="20%">Tilberedning</th>
		</xsl:if>
		<xsl:if test="string-length($konvertertBase64) != 0 and contains($konvertertBase64, 'Legemiddelform')">
			<th width="20%">Legemiddelform</th>
		</xsl:if>
		<xsl:if test="string-length($konvertertBase64) != 0 and (contains($konvertertBase64, 'BestanddelLegemiddel') or contains($konvertertBase64, 'BestanddelAnnet') or contains($konvertertBase64, 'BestanddelVirkestoff'))">
			<th width="20%">Bestanddel</th>
		</xsl:if>
	</xsl:template>
	<xsl:template name="fellesLegemiddelKortTopp">
		<xsl:param name="konvertertBase64"/>
		<xsl:if test="string-length($konvertertBase64) != 0 and contains($konvertertBase64, 'Reseptgruppe')">
			<th width="25%">Reseptgruppe</th>
		</xsl:if>
		<xsl:if test="string-length($konvertertBase64) != 0 and contains($konvertertBase64, 'NavnFormStyrke')">
			<th width="25%">NavnFormStyrke</th>
		</xsl:if>
	</xsl:template>
	<xsl:template name="fellesLegemiddelAvsluttningTopp">
		<xsl:if test="../m2:IngenTidlBehandling">
			<th>Årsak til at forhåndsgodkjenning ikke er forsøkt</th>
		</xsl:if>
		<xsl:if test="string-length($vedlegg) != 0">
			<th>Søknadssvar</th>
		</xsl:if>
	</xsl:template>
	<xsl:template name="fellesLegemiddelBunn">
		<xsl:param name="konvertertBase64"/>
		<xsl:if test="string-length($konvertertBase64) != 0 and contains($konvertertBase64, 'Navn')">
			<td width="20%" valign="top">
				<xsl:value-of select="substring-before(substring-after($konvertertBase64, 'Navn&gt;'),'&lt;/')"/>
			</td>
		</xsl:if>
		<xsl:if test="string-length($konvertertBase64) != 0 and contains($konvertertBase64, 'TilbOppl')">
			<td width="20%" valign="top">
				<xsl:value-of select="substring-before(substring-after($konvertertBase64, 'TilbOppl&gt;'),'&lt;/')"/>
			</td>
		</xsl:if>
		<xsl:if test="string-length($konvertertBase64) != 0 and contains($konvertertBase64, 'Legemiddelform')">
			<td width="20%" valign="top">
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($konvertertBase64,'Legemiddelform '),'/'),'DN=&quot;'),'&quot;')"/>
			</td>
		</xsl:if>
		<xsl:if test="string-length($konvertertBase64) != 0 and (contains($konvertertBase64, 'BestanddelLegemiddel') or contains($konvertertBase64, 'BestanddelAnnet') or contains($konvertertBase64, 'BestanddelVirkestoff'))">
			<td width="20%" valign="top">
				<xsl:if test="contains($konvertertBase64, 'BestanddelLegemiddel')">
					<xsl:call-template name="skrivUtBestanddelLegemiddel">
						<xsl:with-param name="tekst" select="substring-after($konvertertBase64, 'BestanddelLegemiddel&gt;')"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="contains($konvertertBase64, 'BestanddelAnnet')">
					<xsl:call-template name="skrivUtBestanddelAnnet">
						<xsl:with-param name="tekst" select="substring-after($konvertertBase64, 'BestanddelAnnet&gt;')"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="contains($konvertertBase64, 'BestanddelVirkestoff')">
					<xsl:call-template name="skrivUtBestanddelVirkestoff">
						<xsl:with-param name="tekst" select="substring-after($konvertertBase64, 'BestanddelVirkestoff&gt;')"/>
					</xsl:call-template>
				</xsl:if>
			</td>
		</xsl:if>
	</xsl:template>
	<xsl:template name="fellesLegemiddelKortBunn">
		<xsl:param name="konvertertBase64"/>
		<xsl:if test="string-length($konvertertBase64) != 0 and contains($konvertertBase64, 'Reseptgruppe')">
			<td width="25%" valign="top">
				<xsl:choose>
					<xsl:when test="string-length(substring-before(substring-after(substring-before(substring-after($konvertertBase64,'Reseptgruppe '),'/'),'DN=&quot;'),'&quot;'))>0">
					<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($konvertertBase64,'Reseptgruppe '),'/'),'DN=&quot;'),'&quot;')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($konvertertBase64,'Reseptgruppe '),'/'),'V=&quot;'),'&quot;')"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</xsl:if>
		<xsl:if test="string-length($konvertertBase64) != 0 and contains($konvertertBase64, 'NavnFormStyrke')">
			<td width="25%" valign="top">
				<xsl:value-of select="substring-before(substring-after($konvertertBase64, 'NavnFormStyrke&gt;'),'&lt;/')"/>
			</td>
		</xsl:if>
	</xsl:template>
	<xsl:template name="fellesLegemiddelAvsluttningBunn">
		<xsl:param name="refId"/>
		<xsl:if test="../m2:IngenTidlBehandling">
			<td valign="top">
				<xsl:for-each select="../m2:IngenTidlBehandling">
					<xsl:call-template name="k-7507"/>
				</xsl:for-each>
			</td>
		</xsl:if>
		<xsl:if test="string-length($vedlegg) != 0">
			<td>
				<xsl:choose>
					<xsl:when test="count($vedlegg//m12:Soknadssvar) != 0">
						<xsl:choose>
							<xsl:when test="count($vedlegg//m12:Soknadssvar[$refId = m12:RefSoknad]) != 0">
								<xsl:value-of select="$vedlegg//m12:Soknadssvar[$refId = m12:RefSoknad]/m12:Beslutning/@DN"/>
							</xsl:when>
							<xsl:otherwise>
							Mangler vedlagt søknadssvar med samsvarende referanse
						</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
					Mangler vedlagt søknadssvar
				</xsl:otherwise>
				</xsl:choose>
			</td>
		</xsl:if>
	</xsl:template>
	<xsl:template name="skrivUtBestanddelLegemiddel">
		<xsl:param name="tekst"/>
		<div>
			<xsl:if test="contains($tekst, 'NavnFormStyrke')">
				<xsl:value-of select="substring-before(substring-after($tekst, 'NavnFormStyrke&gt;'),'&lt;/')"/>&#160;
			</xsl:if>
			<xsl:if test="contains($tekst, 'Mengde')">
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Mengde '),'/'),'V=&quot;'),'&quot;')"/>&#160;
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Mengde '),'/'),'U=&quot;'),'&quot;')"/>
			</xsl:if>
			<xsl:if test="contains($tekst, 'Utblanding')">
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Adqs '),'/'),'DN=&quot;'),'&quot;')"/>&#160;
			</xsl:if>
		</div>
		<xsl:if test="contains(substring-after($tekst,'BestanddelLegemiddel&gt;'), 'BestanddelLegemiddel')">
			<xsl:call-template name="skrivUtBestanddelLegemiddel">
				<xsl:with-param name="tekst" select="substring-after(substring-after($tekst,'BestanddelLegemiddel&gt;'),'BestanddelLegemiddel&gt;')"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template name="skrivUtBestanddelAnnet">
		<xsl:param name="tekst"/>
		<div>
			<xsl:if test="contains($tekst, 'NavnFormStyrke')">
				<xsl:value-of select="substring-before(substring-after($tekst, 'NavnFormStyrke&gt;'),'&lt;/')"/>&#160;
			</xsl:if>
			<xsl:if test="contains($tekst, 'Mengde')">
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Mengde '),'/'),'V=&quot;'),'&quot;')"/>&#160;
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Mengde '),'/'),'U=&quot;'),'&quot;')"/>
			</xsl:if>
			<xsl:if test="contains($tekst, 'Utblanding')">
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Adqs '),'/'),'DN=&quot;'),'&quot;')"/>&#160;
			</xsl:if>
			<xsl:if test="contains($tekst, 'Styrke')">
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Teller '),'/'),'V=&quot;'),'&quot;')"/>
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Teller '),'/'),'U=&quot;'),'&quot;')"/>&#160;/&#160;
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Nevner '),'/'),'V=&quot;'),'&quot;')"/>
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Nevner '),'/'),'U=&quot;'),'&quot;')"/>
			</xsl:if>
		</div>
		<xsl:if test="contains(substring-after($tekst,'BestanddelAnnet&gt;'), 'BestanddelAnnet')">
			<xsl:call-template name="skrivUtBestanddelAnnet">
				<xsl:with-param name="tekst" select="substring-after(substring-after($tekst,'BestanddelAnnet&gt;'),'BestanddelAnnet&gt;')"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template name="skrivUtBestanddelVirkestoff">
		<xsl:param name="tekst"/>
		<div>
			<xsl:if test="contains($tekst, 'Navn')">
				<xsl:value-of select="substring-before(substring-after($tekst, 'Navn&gt;'),'&lt;/')"/>&#160;
			</xsl:if>
			<xsl:if test="contains($tekst, 'Mengde')">
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Mengde '),'/'),'V=&quot;'),'&quot;')"/>&#160;
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Mengde '),'/'),'U=&quot;'),'&quot;')"/>
			</xsl:if>
			<xsl:if test="contains($tekst, 'Styrke')">
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Teller '),'/'),'V=&quot;'),'&quot;')"/>
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Teller '),'/'),'U=&quot;'),'&quot;')"/>&#160;/&#160;
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Nevner '),'/'),'V=&quot;'),'&quot;')"/>
				<xsl:value-of select="substring-before(substring-after(substring-before(substring-after($tekst,'Nevner '),'/'),'U=&quot;'),'&quot;')"/>
			</xsl:if>
		</div>
		<xsl:if test="contains(substring-after($tekst,'BestanddelVirkestoff&gt;'), 'BestanddelVirkestoff')">
			<xsl:call-template name="skrivUtBestanddelVirkestoff">
				<xsl:with-param name="tekst" select="substring-after(substring-after($tekst,'BestanddelVirkestoff&gt;'),'BestanddelVirkestoff&gt;')"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
