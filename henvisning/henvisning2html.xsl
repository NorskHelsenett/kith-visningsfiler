<?xml version="1.0" encoding="UTF-8"?>
<!--

Endringslogg
- 01.02.24: v5.3.2 - Endret kolonneoveskrift i Legemiddelopplysninger fra Legemiddel til Virkestoff
- 17.10.23: v5.3.1 - Tydeliggjøring av Behov for Tolk - Språk
- 09.08.22: v5.3.0 - Semantisk HTML
- 25.05.22: v5.2.0 - Oppdatert Footer (Dokumentinformasjon)
- 16.05.22: v5.1.2 - Legg til fødselsdag og kjønn i Header hvis fødselsnummer ikke finnes + kopimottakere i Header på egen linje
- 11.10.21: v5.1.1 - Definer Anonymisert, fjern template AddressHode
- 03.09.21: v5.1.0 - Endre oppsett Header. Kodeverk 8244 i rød tekst.
- 04.06.21: v5.0.4 - Lagt til xsl:output for å definere at output formatet skal være html
- 01.06.21: v5.0.3 - Endringer i Dokumentinformasjon. Flyttet Meldingsstatus inni tabellen og endret størrelse på feltet for dato og klokkesett bak Melding opprettet.
- 31.05.21: v5.0.2 - Tillate MimeType (vedlegg) med store bokstaver
- 12.05.21: v5.0.1 - Fjern No-line-content i tabeller og tomme <div>'s
- 08.04.21: v5.0.0 - Endre <span> til <div>, siden block-elementer (<ul>) inni inline-elementer (<span>) kan gi feil visning.
- 10.11.20: v4.1.13 - Flyttet Prognose og Symptom under Kliniske opplysninger og Smitte under NB-opplysninger
- 25.01.19: v4.1.12 - Endret overskrifter
- 19.06.18: v4.1.11 - Fjernet unødvendige overskrifter i legemiddelvisning.
- 06.06.18: v4.1.10 - Bugfix hvor 'Andre relevante tilstander' var satt til å bli oppgitt i elementet ReasonAsText istedet for InfItem. Endret 'CAVE' til 'Kritisk informasjon'.
- 03.05.18: v4.1.9 - Bugfix hvor informasjon ang. KontaktpersonHelspersonell ikke ble vist
- 11.04.18: v4.1.8 - Noen endringer i overskrifter. Fikset bug hvor informasjon om nærmeste pårørende ikke ble vist. La til visning av Legemiddelgjennomgang fra poKomponent.
- 05.01.18: v4.1.7 - Tilpasset til Henvisning v2.0
- 20.06.17: v4.1.6 - Fjernt skillelinje under Helstjenesteenheter for avd. på samme. Erstattet hairspace med puncspace som mellomromtegn.
- 06.06.17: v4.1.5 - Adresse i Kontaktopplysninger: fjernet ledetekst type når adresse mangler.
- 17.03.17: v4.1.4 - Ny stil "Smooth".
- 07.03.17: v4.1.3 - Ny global parameter for "visningStil" fra kommando-linjen. Html/Css responsive.
- 07.02.17: v4.1.2 - Endret kodeverk fra 7319 til 8254 for v1.1 vedr. relasjonstype for helseperson.
- 13.01.16: v4.1.1 - Fix av CSS vedr. lang tekst i siste kolonne.
- 15.11.16: v4.1.0 - Inkluderer v2.0. Noe css-tilpasning for IE7/8.
- 26.10.16: v4.0.0 - Opprettet felles visning for alle versjonene av henvisning. (v1.0, v1.1)

Design:
- Responsive kollaps ved 767px bredde.
Om:
- Inngår i Direktoratet for e-helse visningsfiler

-->
<xsl:stylesheet version="1.0"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1"
	xmlns:base="http://www.kith.no/xmlstds/base64container"
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24"
	xmlns:doc10="http://www.kith.no/xmlstds/henvisning/2005-07-08"
	xmlns:doc11="http://www.kith.no/xmlstds/henvisning/2012-02-15"
	exclude-result-prefixes="xhtml fk1 base mh" >

	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../felleskomponenter/cave2html.xsl"/>
	<xsl:import href="../felleskomponenter/journalnotat2html.xsl"/>
	<xsl:import href="../felleskomponenter/poKomponent2html.xsl"/>
	<xsl:import href="../felleskomponenter/eh-komponent1.xsl"/>
	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'henvisning v.uavhengig - v5.3.2'"/>

	<xsl:variable name="VisOvrigHelsetjenesteInfoVisSkjul" select="true()"/>
	<xsl:variable name="VisDokInfoVisSkjul" select="true()"/>
	<xsl:variable name="VisRefDokVisSkjul" select="true()"/>

    <xsl:variable name="Anonymisert" select="false()"/>

    <xsl:variable name="IsTestMessage" select="
		boolean(/doc10:Message/doc10:Status[@V = 'TEST'])
		or boolean(/doc11:Message/doc11:Status[@V = 'TEST'])
		or boolean(/mh:MsgHead/mh:MsgInfo/mh:ProcessingStatus[@V = 'D'])" />

	<xsl:param name="VisMenylinje"/>

	<xsl:variable name="menylinje">
		<xsl:choose>
			<xsl:when test="$VisMenylinje = 'false'">
				<xsl:value-of select="false()"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="true()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	 <xsl:template match="/">
		<html>
			<head>
				<title>Henvisning</title>
				<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/KITH-visning.css')" disable-output-escaping="yes"/>
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/ehelse-visning.css')" disable-output-escaping="yes"/>
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/smooth-visning.css')" disable-output-escaping="yes"/>
				</style>
			</head>
			<body>
				<xsl:if test="$IsTestMessage">
					<p class="TestMessageWarning">OBS: Dette er en testmelding.</p>
				</xsl:if>
				<xsl:for-each select="child::*[local-name()='Message']">  <!-- v1.0, v1.1 -->
					<xsl:call-template name="Message"/>
				</xsl:for-each>
				<xsl:apply-templates select="mh:MsgHead"/> <!-- v2.0 -->
			</body>
		</html>
	</xsl:template>

	<!-- Visning av meldingshodet. Tilpasset vinduskonvolutt ved utskrift -->
	<xsl:template match="mh:MsgHead">  <!-- v2.0 -->
		<xsl:call-template name="Topp"/>
		<xsl:call-template name="Innhold">
			<xsl:with-param name="menylinje" select="$menylinje"/>
		</xsl:call-template>
		<xsl:call-template name="Bunn"/>
	</xsl:template>

	<xsl:template name="Message">  <!-- v1.0, v1.1 -->
		<xsl:for-each select="child::*[local-name()='ServReq']">
			<!-- utelater meldingsid og kommunikasjonsinformasjon -->
			<xsl:call-template name="Header"/>
			<xsl:call-template name="ResultBody">
				<xsl:with-param name="menylinje" select="$menylinje"/>
			</xsl:call-template>
			<xsl:call-template name="Footer">
				<xsl:with-param name="stil" select="$stil"/>
				<xsl:with-param name="versjon" select="$versjon"/>
				<xsl:with-param name="VisDokInfoVisSkjul" select="$VisDokInfoVisSkjul"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Meldingshodet - avsender og mottaker-informasjon -->
	<xsl:template name="Header">
		<header class="No-line-top" style="display: flex;">
			<section class="No-line-header Patient">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='Patient']">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Pasient&#160;</div>
							<div class="No-line-content">
								<xsl:for-each select="child::*[local-name()='Patient']">
									<xsl:choose>
										<xsl:when test="not($Anonymisert)">
											<xsl:value-of select="child::*[local-name()='Name']"/>&#160;
										</xsl:when>
										<xsl:otherwise>Gundersen,&#160;Roland&#160;</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</div>
						</div>
						<xsl:if test="child::*[local-name()='Patient']/child::*[local-name()='TypeOffId'] or child::*[local-name()='Patient']/child::*[local-name()='OffId']">
							<div class="No-line-headerContent">
								<div class="No-line-caption">
									<xsl:choose>
										<xsl:when test="not($Anonymisert)">
											<xsl:for-each select="child::*[local-name()='Patient']/child::*[local-name()='TypeOffId']">
												<xsl:call-template name="k-8116"/>
											</xsl:for-each>&#160;
										</xsl:when>
										<xsl:otherwise>Fødselsnummer&#160;</xsl:otherwise>
									</xsl:choose>
								</div>
								<div class="No-line-content">
									<xsl:choose>
										<xsl:when test="not($Anonymisert)">
											<xsl:value-of select="child::*[local-name()='Patient']/child::*[local-name()='OffId']"/>&#160;
										</xsl:when>
										<xsl:otherwise>15076500565</xsl:otherwise>
									</xsl:choose>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="not(child::*[local-name()='Patient']/child::*[local-name()='TypeOffId'] and child::*[local-name()='Patient']/child::*[local-name()='OffId']) and child::*[local-name()='Patient']/child::*[local-name()='DateOfBirth']">
							<div class="No-line-headerContent">
								<div class="No-line-caption">Fødselsdag&#160;</div>
								<div class="No-line-content">
									<xsl:choose>
										<xsl:when test="not($Anonymisert)">
											<xsl:call-template name="skrivUtDate">
												<xsl:with-param name="oppgittTid" select="child::*[local-name()='Patient']/child::*[local-name()='DateOfBirth']/@V"/>
												<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>15.07.65</xsl:otherwise>
									</xsl:choose>
								</div>
							</div>
							<xsl:if test="child::*[local-name()='Patient']/child::*[local-name()='Sex']">
								<div class="No-line-headerContent">
									<div class="No-line-caption">Kjønn&#160;</div>
									<div class="No-line-content">
										<xsl:choose>
											<xsl:when test="not($Anonymisert)">
												<xsl:for-each select="child::*[local-name()='Patient']/child::*[local-name()='Sex']">
													<xsl:call-template name="k-3101"/>&#160;
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>Mann</xsl:otherwise>
										</xsl:choose>
									</div>
								</div>
							</xsl:if>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<div class="No-line-headerContent">
							<div class="NoScreen">&#160;</div>
						</div>
					</xsl:otherwise>
				</xsl:choose>
			</section>

			<section class="No-line-header Sender">
				<div class="No-line-headerContent">
					<div class="No-line-caption">Avsender&#160;</div>
					<div class="No-line-content">
						<xsl:for-each select="child::*[local-name()='Requester']">
							<xsl:call-template name="RequesterHode"/>
						</xsl:for-each>
					</div>
				</div>
				<div class="No-line-headerContent">
					<div class="No-line-caption">Mottaker&#160;</div>
					<div class="No-line-content">
						<xsl:for-each select="child::*[local-name()='ServProvider']">
							<xsl:call-template name="ServProviderHode"/>
						</xsl:for-each>
					</div>
				</div>
				<xsl:choose>
					<xsl:when test="child::*[local-name()='CopyDest']">
						<xsl:for-each select="child::*[local-name()='CopyDest']">
							<div class="No-line-headerContent">
								<div class="No-line-caption">Kopimottaker&#160;</div>
								<div class="No-line-content">
									<xsl:call-template name="CopyDestHode"/>
								</div>
							</div>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<div class="No-line-headerContent">
							<div class="NoScreen">&#160;</div>
						</div>
					</xsl:otherwise>
				</xsl:choose>
			</section>
		</header>
	</xsl:template>

	<xsl:template name="RequesterHode">
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCPHode"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="ServProviderHode">
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCPHode"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="HCPersonHode">
		<div>
			<xsl:value-of select="child::*[local-name()='Name']"/>&#160;
		</div>
	</xsl:template>

	<xsl:template name="HCPHode">
		<xsl:for-each select="child::*[local-name()='Inst']">
			<xsl:call-template name="InstHode"/>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='HCProf']">
			<xsl:call-template name="HCProfHode"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="InstHode">
		<xsl:for-each select="child::*[local-name()='HCPerson']">
			<xsl:call-template name="HCPersonHode"/>
		</xsl:for-each>
		<div>
			<div class="NoPrint">
				<b>Institusjon:&#160;</b>
			</div>
			<xsl:value-of select="child::*[local-name()='Name']"/>
		</div>
		<xsl:for-each select="child::*[local-name()='Dept']">
			<div>
				<div class="NoPrint">-&#160;</div>
				<xsl:value-of select="child::*[local-name()='Name']"/>&#160;
			</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="HCProfHode">
		<div>
			<xsl:for-each select="child::*[local-name()='Type']">
				<xsl:call-template name="k-9060"/>&#160;
			</xsl:for-each>
			<xsl:value-of select="child::*[local-name()='Name']"/>
		</div>
	</xsl:template>

	<xsl:template name="CopyDestHode">
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCPHode"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="Innhold">
		<xsl:for-each select="//child::*[local-name()='Henvisning']">
			<xsl:call-template name="ResultBody"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Hoveddokumentet -->
	<xsl:template name="ResultBody"> <!-- /Message/ServReq (v1.0, v1.1) eller  /MsgHead/Document/Content/Henvisning (v2.0)  -->
		<xsl:variable name="position" select="position()"/>
		<xsl:variable name="color">
			<xsl:choose>
				<xsl:when test="child::*[local-name()='ServType'][@V='M' or @V='C' or @V='O']">red</xsl:when>
				<xsl:otherwise>black</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="color2">
			<xsl:choose>
				<xsl:when test="child::*[local-name()='ReqServ']/child::*[local-name()='ServType'][@V='M' or @V='C' or @V='O']">red</xsl:when>
				<xsl:otherwise>black</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<main class="{$stil}">
			<xsl:if test="$menylinje = 'true'">
				<xsl:call-template name="FellesMeny">
					<xsl:with-param name="position" select="position()"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Overskrift for henvisningen -->
			<h1>
				<xsl:choose>
					<xsl:when test="namespace-uri() = 'http://ehelse.no/xmlstds/henvisning/2017-11-30'">
						<xsl:value-of select="/mh:MsgHead/mh:MsgInfo/mh:Type/@DN"/>
					</xsl:when>
					<xsl:otherwise>Henvisning&#160;-&#160;<xsl:for-each select="child::*[local-name()='MsgDescr']">
							<xsl:call-template name="k-8455"/>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:for-each select="child::*[local-name()='ServType'][@V!='N']">&#160;-<span style="color: {$color};">
						<xsl:call-template name="k-7309"/>
					</span>
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='ReqServ']/child::*[local-name()='ServType'][@V!='N']">&#160;Status&#160;rekvirert&#160;tjeneste:&#160;-<span style="color: {$color2};">
						<xsl:call-template name="k-7309"/>
					</span>
				</xsl:for-each>
			</h1>

			<section class="eh-section">
				<xsl:call-template name="ServReq_Henvisning"/> <!-- v1.0, v1.1, v2.0 -->

				<xsl:choose>
					<xsl:when test="//child::*[local-name()='ServReq']/child::*[local-name()='ReqComment']"> <!-- v1.0 og v1.1 -->
						<div class="eh-row-4">
							<div class="eh-label">Kommentar</div>
					    	<div class="eh-col-4 eh-last-child">
						    	<div class="eh-field">
							    	<xsl:call-template name="line-breaks">
								    	<xsl:with-param name="text" select="//child::*[local-name()='ServReq']/child::*[local-name()='ReqComment']"/>
								    </xsl:call-template>
							    </div>
						    </div>
					    </div>
				    </xsl:when>
					<xsl:otherwise>
						<xsl:if test="//child::*[local-name()='ReqComment']">
							<div class="eh-row-4">
								<div class="eh-col-4 eh-last-child">
									<div class="eh-label">Kommentar</div>
									<div class="eh-field">
										<xsl:call-template name="line-breaks">
											<xsl:with-param name="text" select="//child::*[local-name()='ReqComment']"/>
										</xsl:call-template>
									</div>
								</div>
							</div>
						</xsl:if>

					</xsl:otherwise>
				</xsl:choose>

			</section>

			<!-- Overskrift for Diagnoser -->
			<xsl:if test="child::*[local-name()='Diagnosis'] or child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='DIAG'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='H' or child::*[local-name()='Type']/@V='B']">
				<xsl:variable name="id10">
					<xsl:value-of select="concat('Diagnosis',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id10}">Diagnoser</h2>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='Diagnosis']">
							<xsl:call-template name="Diagnosis"/>
						</xsl:for-each>
						<xsl:for-each select="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='DIAG']">
							<div class="eh-row-5">
								<div class="eh-col-1">
									<div class="eh-label">Henvisningsdiagnose</div>
									<div class="eh-field">
										<xsl:call-template name="line-breaks">
											<xsl:with-param name="text" select="child::*[local-name()='TextResultValue']"/>
										</xsl:call-template>
									</div>
								</div>
							</div>
						</xsl:for-each>

						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='H' or child::*[local-name()='Type']/@V='B']">
							<xsl:for-each select="child::*[local-name()='ResultItem']">
								<xsl:call-template name="eh-ResultItem" />
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Medication']">
								<xsl:call-template name="eh-Medication" />
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Observation']">
								<xsl:call-template name="eh-Observation" />
							</xsl:for-each>
							<!-- Men ResultItem og Medication er kankje ikke aktuell herfra siden rad-element mangler ?? -->
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for CAVE og NB-opplysninger -->
			<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='CAVE' or child::*[local-name()='Type']/@V='NB' or child::*[local-name()='Type']/@V='SM']">
				<xsl:variable name="id20">
					<xsl:value-of select="concat('CAVE',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id20}">
						<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='CAVE']">Kritisk informasjon</xsl:if>
						<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='CAVE' and (child::*[local-name()='Type']/@V='NB' or child::*[local-name()='Type']/@V='SM')]">&#160;og&#160;</xsl:if>
						<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='NB' or child::*[local-name()='Type']/@V='SM']">NB-opplysninger</xsl:if>
					</h2>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='CAVE' or child::*[local-name()='Type']/@V='NB' or child::*[local-name()='Type']/@V='SM']">
							<xsl:for-each select="child::*[local-name()='ResultItem']">
								<xsl:call-template name="eh-ResultItem"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Medication']">
								<xsl:call-template name="eh-Medication"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Observation']">
								<xsl:call-template name="eh-Observation"/>
							</xsl:for-each>
							<!-- Men ResultItem og Medication er kankje ikke aktuell herfra siden rad-element mangler ?? -->
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Aktuell problemstilling -->
			<xsl:if test="//child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='PROB']">
				<xsl:variable name="id30">
					<xsl:value-of select="concat('PROB',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id30}">Aktuell problemstilling</h2>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='PROB']">
							<xsl:call-template name="eh-ReasonAsText"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Andre relevante tilstander -->
			<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='ART']">
				<xsl:variable name="id35">
					<xsl:value-of select="concat('ART',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id35}">Andre relevante tilstander</h2>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='ART']">
							<xsl:for-each select="child::*[local-name()='ResultItem']">
								<xsl:call-template name="eh-ResultItem"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Medication']">
								<xsl:call-template name="eh-Medication"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Observation']">
								<xsl:call-template name="eh-Observation"/>
							</xsl:for-each>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Forventet utredning/behandling -->
			<xsl:if test="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='UTRED']">
				<xsl:variable name="id40">
					<xsl:value-of select="concat('UTRED',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id40}">Forventet utredning/behandling</h2>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='UTRED']">
							<xsl:call-template name="eh-ReasonAsText"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Kliniske opplysninger -->
			<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='OPPL' or child::*[local-name()='Type']/@V='SYMP' or child::*[local-name()='Type']/@V='PROG']">
				<xsl:variable name="id50">
					<xsl:value-of select="concat('OPPL',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id50}">Kliniske opplysninger</h2>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='OPPL' or child::*[local-name()='Type']/@V='SYMP' or child::*[local-name()='Type']/@V='PROG']">
							<xsl:for-each select="child::*[local-name()='ResultItem']">
								<xsl:call-template name="eh-ResultItem"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Medication']">
								<xsl:call-template name="eh-Medication"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Observation']">
								<xsl:call-template name="eh-Observation"/>
							</xsl:for-each>
							<!-- Men ResultItem og Medication er kankje ikke aktuell herfra siden rad-element mangler ?? -->
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Gynekologiske opplysninger -->
			<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='GOPL' or child::*[local-name()='Type']/@V='GBEH']">
				<xsl:variable name="id60">
					<xsl:value-of select="concat('GOPL',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id60}">Gynekologiske opplysninger</h2>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='GOPL' or child::*[local-name()='Type']/@V='GBEH']">

							<xsl:for-each select="child::*[local-name()='ResultItem']">
								<xsl:call-template name="eh-ResultItem"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Medication']">
								<xsl:call-template name="eh-Medication"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Observation']">
								<xsl:call-template name="eh-Observation"/>
							</xsl:for-each>
							<!-- Men ResultItem og Medication er kankje ikke aktuell herfra siden rad-element mangler ?? -->
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Spesialistvurdering -->
			<xsl:if test="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='SVU']">
				<xsl:variable name="id70">
					<xsl:value-of select="concat('SVU',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id70}">Spesialistvurdering</h2>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='SVU']">
							<xsl:call-template name="eh-ReasonAsText"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Vurdering -->
			<xsl:if test="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='VU']">
				<xsl:variable name="id80">
					<xsl:value-of select="concat('VU',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id80}">Vurdering</h2>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='VU']">
							<xsl:call-template name="eh-ReasonAsText"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Annen begrunnelse for henvisningen -->
			<xsl:if test="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='BG' or child::*[local-name()='Heading']/@V='BUP-BM' or child::*[local-name()='Heading']/@V='BUP-HG' or child::*[local-name()='Heading']/@V='KF' or child::*[local-name()='Heading']/@V='MAAL' or child::*[local-name()='Heading']/@V='MU' or child::*[local-name()='Heading']/@V='RU' or child::*[local-name()='Heading']/@V='UP' or not(child::*[local-name()='Heading'])]">
				<xsl:variable name="id90">
					<xsl:value-of select="concat('Annen',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id90}">Annen begrunnelse for henvisningen</h2>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='BG' or child::*[local-name()='Heading']/@V='BUP-BM' or child::*[local-name()='Heading']/@V='BUP-HG' or child::*[local-name()='Heading']/@V='KF' or child::*[local-name()='Heading']/@V='MAAL' or child::*[local-name()='Heading']/@V='MU' or child::*[local-name()='Heading']/@V='RU' or child::*[local-name()='Heading']/@V='UP' or not(child::*[local-name()='Heading'])]">
							<xsl:call-template name="eh-ReasonAsText"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Sykehistorie -->
			<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='ANAM' or child::*[local-name()='Type']/@V='TB' or child::*[local-name()='Type']/@V='US']">
				<xsl:variable name="id100">
					<xsl:value-of select="concat('ANAM',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id100}">Sykehistorie</h2>
					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='ANAM' or child::*[local-name()='Type']/@V='TB' or child::*[local-name()='Type']/@V='US']">
							<xsl:for-each select="child::*[local-name()='ResultItem']">
								<xsl:call-template name="eh-ResultItem"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Medication']">
								<xsl:call-template name="eh-Medication"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Observation']">
								<xsl:call-template name="eh-Observation"/>
							</xsl:for-each>
							<!-- Men ResultItem og Medication er kankje ikke aktuell herfra siden rad-element mangler ?? -->
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Funn/undersøkelsesresultat -->
			<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='FUNN'] or child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='FU']">
				<xsl:variable name="id110">
					<xsl:value-of select="concat('ResultItem',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id110}">Funn/undersøkelsesresultat</h2>
					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='FUNN']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
						<!-- ORG <xsl:for-each select="//child::*[local-name()='ResultItem']">-->
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='FUNN']/child::*[local-name()='ResultItem']">
							<!-- <xsl:if test="position()=1">
								<div class="eh-row-8">
									<div class="eh-col-1 md eh-label">Under&#173;søkelse</div>
									<div class="eh-col-3 md eh-label">Funn/&#173;resultat</div>
									<xsl:if test="//child::*[local-name()='ResultItem']/child::*[local-name()='InvDate']">
										<div class="eh-col-1 md eh-label">Tidspunkt for under&#173;søkelsen</div>
									</xsl:if>
									<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='StartDateTime']">
										<div class="eh-col-1 md eh-label">Start&#173;tidspunkt</div>
									</xsl:if>
									<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='EndDateTime']">
										<div class="eh-col-1 md eh-label">Sluttidspunkt</div>
									</xsl:if>
									<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='OrgDate']">
										<div class="eh-col-1 md eh-label">Tidspunkt for opprinnelse</div>
									</xsl:if>
								</div>
							</xsl:if>
							-->
							<div class="eh-row-8">
								<xsl:call-template name="eh-ResultItem"/>
							</div>

						</xsl:for-each>
						<xsl:for-each select="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='FU']">
							<xsl:call-template name="eh-ReasonAsText"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Prosedyrer -->
			<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='OPIN' or child::*[local-name()='Type']/@V='MPRS' or child::*[local-name()='Type']/@V='PRS']">
				<xsl:variable name="id120">
					<xsl:value-of select="concat('OPIN',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id120}">Prosedyrer</h2>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='OPIN' or child::*[local-name()='Type']/@V='MPRS' or child::*[local-name()='Type']/@V='PRS']">
							<xsl:for-each select="child::*[local-name()='ResultItem']">
								<xsl:call-template name="eh-ResultItem"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Medication']">
								<xsl:call-template name="eh-Medication"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Observation']">
								<xsl:call-template name="eh-Observation"/>
							</xsl:for-each>
							<!-- Men ResultItem og Medication er kankje ikke aktuell herfra siden rad-element mangler ?? -->
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Forløp og behandling -->
			<xsl:if test="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='FO']">
				<xsl:variable name="id130">
					<xsl:value-of select="concat('FO',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id130}">Forløp og behandling</h2>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='FO']">
							<xsl:call-template name="eh-ReasonAsText"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Funksjonsnivå/hjelpetiltak -->
			<xsl:if test="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='HJ']">
				<xsl:variable name="id140">
					<xsl:value-of select="concat('HJ',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id140}">Funksjonsnivå/hjelpetiltak</h2>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='HJ']">
							<xsl:call-template name="eh-ReasonAsText"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Legemiddelopplysninger -->
			<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='MEDB'] or child::*[local-name()='Legemiddelgjennomgang']">
				<xsl:variable name="id150">
					<xsl:value-of select="concat('Medication',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id150}">Legemiddelopplysninger</h2>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='MEDB']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='MEDB']/child::*[local-name()='ResultItem']">
							<xsl:call-template name="eh-ResultItem"/> <!-- Mangler rad-element for ResultItem -->
						</xsl:for-each>

						<xsl:for-each select="//child::*[local-name()='Medication']">
							<xsl:variable name="stripedCss">
								<xsl:choose>
									<xsl:when test="boolean(position() mod 2)">striped</xsl:when>
									<xsl:otherwise></xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:if test="position()=1">
								<div class="eh-row-8">
									<div class="eh-col-2-xs eh-label">Virkestoff</div>
									<div class="eh-col-1-xs eh-label">Status</div>
									<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='UnitDose'] or //child::*[local-name()='Medication']/child::*[local-name()='QuantitySupplied']">
										<div class="eh-col-1-xs eh-label">Mengde</div>
									</xsl:if>
									<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='DosageText'] or //child::*[local-name()='Medication']/child::*[local-name()='IntendedDuration']">
										<div class="eh-col-1 eh-label">
											<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='DosageText']">Dosering</xsl:if>
											<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='DosageText'] and //child::*[local-name()='Medication']/child::*[local-name()='IntendedDuration']">/</xsl:if>
											<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='IntendedDuration']">Varighet</xsl:if>
										</div>
									</xsl:if>
									<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='Comment']">
										<div class="eh-col-2 eh-label">Kommentar</div>
									</xsl:if>
									<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Medication']]/child::*[local-name()='StartDateTime']">
										<div class="eh-col-1-md eh-label">Starttidspunkt</div>
									</xsl:if>
									<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Medication']]/child::*[local-name()='EndDateTime']">
										<div class="eh-col-1-md eh-label">Sluttidspunkt</div>
									</xsl:if>
									<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Medication']]/child::*[local-name()='OrgDate']">
										<div class="eh-col-1-md eh-label">Tidspunkt for opprinnelse</div>
									</xsl:if>
								</div>
							</xsl:if>
							<div class="eh-row-8 {$stripedCss}" >
								<xsl:call-template name="eh-Medication">
									<xsl:with-param name="striped" select="$stripedCss"/>
								</xsl:call-template>
							</div>
						</xsl:for-each>

						<xsl:for-each select="child::*[local-name()='Legemiddelgjennomgang']">
							<div class="eh-row-4">
								<xsl:if test="child::*[local-name()='DatoLegemiddelgjennomgang']">
									<div class="eh-col-1">
										<div class="eh-label">Dato for siste legemiddelgjennomgang</div>
										<div class="eh-field">
											<xsl:call-template name="skrivUtDate">
												<xsl:with-param name="oppgittTid" select="child::*[local-name()='DatoLegemiddelgjennomgang']"/>
											</xsl:call-template>
										</div>
									</div>
								</xsl:if>

								<xsl:if test="child::*[local-name()='DatoSamstemming']">
									<div class="eh-col-1">
										<div class="eh-label">Dato for siste samstemming</div>
										<div class="eh-field">
											<xsl:call-template name="skrivUtDate">
												<xsl:with-param name="oppgittTid" select="child::*[local-name()='DatoSamstemming']"/>
											</xsl:call-template>
										</div>
									</div>
								</xsl:if>

								<xsl:if test="child::*[local-name()='Merknad']">
									<div class="eh-col-2 eh-last-child">
										<div class="eh-label">Merknad</div>
										<div class="eh-field">
											<xsl:call-template name="line-breaks">
												<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
											</xsl:call-template>
										</div>
									</div>
								</xsl:if>
							</div>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Familie/sosialt -->
			<xsl:if test="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='FA']">
				<xsl:variable name="id160">
					<xsl:value-of select="concat('FA',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id160}">Familie/sosialt</h2>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='FA']">
							<xsl:call-template name="eh-ReasonAsText"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Informasjon til pasient/pårørende -->
			<xsl:if test="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='IP']">
				<xsl:variable name="id170">
					<xsl:value-of select="concat('IP',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id170}">Informasjon til pasient/pårørende</h2>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='IP']">
							<xsl:call-template name="eh-ReasonAsText"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Sykemelding -->
			<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='SYKM']">
				<xsl:variable name="id180">
					<xsl:value-of select="concat('SYKM',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id180}">Sykemelding</h2>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='SYKM']">
							<xsl:for-each select="child::*[local-name()='ResultItem']">
								<xsl:call-template name="eh-ResultItem"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Medication']">
								<xsl:call-template name="eh-Medication"/>
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='Observation']">
								<xsl:call-template name="eh-Observation"/>
							</xsl:for-each>
							<!-- Men ResultItem og Medication er kankje ikke aktuell herfra siden rad-element mangler -->
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Pakkeforløp -->
		    <!-- Overskrift for pakkeforløp -->
			<xsl:if test="child::*[local-name()='Pakkeforlop']">
				<xsl:variable name="id185">
					<xsl:value-of select="concat('Pakkeforlop',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id185}">Pakkeforløp</h2>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='Pakkeforlop']">
							<xsl:variable name="stripedCss">
								<xsl:choose>
									<xsl:when test="boolean(position() mod 2)">striped</xsl:when>
									<xsl:otherwise></xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:if test="position()=1">
								<div class="eh-row-8">
									<div class="eh-col-1 eh-label">Kode</div>
									<div class="eh-col-2 eh-label">Navn</div>
									<xsl:if test="//child::*[local-name()='Merknad']">
										<div class="eh-col-3 eh-label">Merknad</div>
									</xsl:if>
								</div>
							</xsl:if>
							<div class="eh-row-8 {$stripedCss}" >
								<xsl:call-template name="eh-Pakkeforlop">
									<xsl:with-param name="striped" select="$stripedCss"/>
								</xsl:call-template>
							</div>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for Kommentarer -->
			<xsl:if test="child::*[local-name()='Comment']">
				<xsl:variable name="id190">
					<xsl:value-of select="concat('Comment',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id190}">Kommentarer</h2>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='Comment']">
							<div class="eh-row-5">
								<div class="eh-col-1 eh-last-child">
									<div class="eh-label">
										<xsl:choose>
											<xsl:when test="child::*[local-name()='Heading']">
												<xsl:for-each select="child::*[local-name()='Heading']">
													<xsl:call-template name="k-8234"/>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>Kommentar</xsl:otherwise>
										</xsl:choose>
									</div>
									<div class="eh-field">
										<xsl:if test="child::*[local-name()='TextResultValue']">
											<xsl:value-of select="child::*[local-name()='TextResultValue']"/>
										</xsl:if>
									</div>
									<br/>
									<xsl:for-each select="child::*[local-name()='CodedComment']">
										<xsl:choose>
											<xsl:when test="contains(@S,'8403')">
												<div class="eh-label">Barnevernets rolle</div>
												<div class="eh-field">
													<xsl:call-template name="k-8403"/>
												</div>
												<br/>
											</xsl:when>
											<xsl:when test="contains(@S,'8419')">
												<div class="eh-label">Omsorgssituasjon</div>
												<div class="eh-field">
													<xsl:call-template name="k-8419"/>
												</div>
												<br/>
											</xsl:when>
											<xsl:when test="contains(@S,'9513')">
												<div class="eh-label">Foreldreansvar</div>
												<div class="eh-field">
													<xsl:call-template name="k-9513"/>
												</div>
												<br/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="k-dummy"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</div>
							</div>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="namespace-uri() = 'http://ehelse.no/xmlstds/henvisning/2017-11-30'">
					<!--  v2.0 -->
					<!-- Overskrift for pasientopplysninger  -->
					<xsl:if test="child::*[local-name()='PatientPrecaution'] or child::*[local-name()='BasisForHealthServices'] or child::*[local-name()='TilleggsopplysningPasient'] or child::*[local-name()='Consent'] or child::*[local-name()='ParorendeForesatt'] or child::*[local-name()='InfoAssistertKommunikasjon'] or child::*[local-name()='PasientrelatertKontaktperson']">
						<xsl:variable name="id200"><xsl:value-of select="concat('PatientInformation',$position)"/></xsl:variable>
						<section>
							<h2 id="{$id200}">Pasientopplysninger</h2>
							<div class="eh-section">
								<xsl:call-template name="PatientInformation"/>
							</div>
						</section>
					</xsl:if>

					<!-- Overskrift for Opplysninger om individuell plan -->
					<xsl:if test="child::*[local-name()='OpplysningerOmIndividuellPlan']">
						<section>
							<h2 id="OpplysningerOmIndividuellPlan">Opplysninger&#160;om&#160;individuell&#160;plan</h2>
							<div class="eh-section">
								<div class="eh-row-4">
									<xsl:if test="child::*[local-name()='OpplysningerOmIndividuellPlan']/child::*[local-name()='IndividuellPlanForeligger']">
										<div class="eh-col-1">
											<div class="eh-label">Individuell plan foreligger</div>
											<div class="eh-field">
												<xsl:choose>
													<xsl:when test="child::*[local-name()='OpplysningerOmIndividuellPlan']/child::*[local-name()='IndividuellPlanForeligger']='true'">Ja</xsl:when>
													<xsl:otherwise>Nei</xsl:otherwise>
												</xsl:choose>
											</div>
										</div>
									</xsl:if>
									<xsl:if test="child::*[local-name()='OpplysningerOmIndividuellPlan']/child::*[local-name()='KoordinatorOppnevnt']">
										<div class="eh-col-1">
											<div class="eh-label">Koordinator oppnevnt</div>
											<div class="eh-field">
												<xsl:choose>
													<xsl:when test="child::*[local-name()='OpplysningerOmIndividuellPlan']/child::*[local-name()='KoordinatorOppnevnt']='true'">Ja</xsl:when>
													<xsl:otherwise>Nei</xsl:otherwise>
												</xsl:choose>
											</div>
										</div>
									</xsl:if>
									<xsl:if test="child::*[local-name()='OpplysningerOmIndividuellPlan']/child::*[local-name()='Merknad']">
										<div class="eh-col-1">
											<div class="eh-label">Merknad</div>
											<div class="eh-field">
												<xsl:value-of select="child::*[local-name()='OpplysningerOmIndividuellPlan']/child::*[local-name()='Merknad']"/>
											</div>
										</div>
									</xsl:if>
								</div>
							</div>
						</section>
					</xsl:if>

					<!-- Overskrift for Kontaktopplysninger -->
					<xsl:if test="child::*[local-name()='TilknyttetEnhet'] or child::*[local-name()='KontaktpersonHelsepersonell'] or child::*[local-name()='AnsvarForRapport']">
						<xsl:variable name="id210"><xsl:value-of select="concat('PatRelHCP',$position)"/></xsl:variable>
						<section>
							<h2 id="{$id210}">Kontaktopplysninger</h2>
							<xsl:if test="$VisOvrigHelsetjenesteInfoVisSkjul">
								<label for="vis{$id210}" class="VisSkjul">Vis/Skjul</label>
								<input type="checkbox" checked="true" id="vis{$id210}" style="display: none;"/>
							</xsl:if>
							<div class="eh-section">
								<xsl:call-template name="HealthCareProfessional_v2"/>
							</div>
						</section>
					</xsl:if>

				</xsl:when>

				<xsl:otherwise>
					<!--  v1.0, v1.1 -->

					<!-- Overskrift for Pasient -->
					<xsl:for-each select="child::*[local-name()='Patient']">
						<xsl:if test="child::*[local-name()='PatientPrecaution'] or child::*[local-name()='BasisForHealthServices'] or child::*[local-name()='Sex'] or child::*[local-name()='DateOfBirth'] or child::*[local-name()='PatientPrecaution'] or child::*[local-name()='AssistertKommunikasjon'] or child::*[local-name()='ParorendeForesatt'] or child::*[local-name()='ContactPerson'] or child::*[local-name()='PatRelInst'] or child::*[local-name()='Consent'] or child::*[local-name()='AdditionalId'] or child::*[local-name()='NeedTranslator'] or child::*[local-name()='CareSituation']">
							<xsl:variable name="id200">
								<xsl:value-of select="concat('Patient',$position)"/>
							</xsl:variable>
							<section>
								<h2 id="{$id200}">Pasient</h2>
								<div class="eh-section">
									<xsl:call-template name="Patient_v1"/>
								</div>
							</section>
						</xsl:if>
					</xsl:for-each>

					<!-- Overskrift for Kontaktopplysninger -->
					<xsl:if test="child::*[local-name()='Patient']/child::*[local-name()='PatRelHCP']">
						<xsl:variable name="id210">
							<xsl:value-of select="concat('PatRelHCP',$position)"/>
						</xsl:variable>

						<section>
							<h2 id="{$id210}">Kontaktopplysninger</h2>

							<xsl:if test="$VisOvrigHelsetjenesteInfoVisSkjul">
								<label for="vis{$id210}" class="VisSkjul">Vis/Skjul</label>
								<input type="checkbox" checked="true" id="vis{$id210}" style="display: none;"/>
							</xsl:if>

							<div class="eh-section xs">
								<xsl:call-template name="HealthCareProfessional_v1"/>
							</div>
						</section>
					</xsl:if>

				</xsl:otherwise>
			</xsl:choose>

			<!-- Overskrift for henvisning mellom helseforetak -->
			<xsl:if test="child::*[local-name()='VurderingAvHenvisning']">
				<xsl:variable name="id215"><xsl:value-of select="concat('vurderingHenvisning',$position)"/></xsl:variable>
				<section>
					<h2 id="{$id215}">Rettighetsvurdering</h2>
					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='VurderingAvHenvisning']">
							<xsl:call-template name="VurderingAvHenvisning"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift for vedlegg -->
			<xsl:if test="child::*[local-name()='RefDoc'] or count(//mh:RefDoc) &gt; 1">
				<xsl:variable name="id220">
					<xsl:value-of select="concat('RefDoc',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id220}">Vedlegg</h2>

					<xsl:if test="$VisRefDokVisSkjul">
						<label for="vis{$id220}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id220}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='RefDoc']"> <!-- v1.0, v1.1 -->
							<xsl:call-template name="eh-RefDoc"/>
						</xsl:for-each>

						<xsl:for-each select="//mh:RefDoc"> <!-- v2.0 -->
							<xsl:if test="position() != 1">
								<div class="eh-section">
									<xsl:call-template name="eh-msghead-RefDoc" />
								</div>
							</xsl:if>
						</xsl:for-each>

					</div>
				</section>
			</xsl:if>
		</main>
	</xsl:template>

	<!-- Meldingshodet - Dokumentopplysninger -->
	<xsl:template name="Footer"> <!-- v1.0, v1.1 -->
		<footer class="{$stil}">

			<h2>Dokumentinformasjon</h2>

			<xsl:if test="$VisDokInfoVisSkjul">
				<label for="visFooter" class="VisSkjul">Vis/Skjul</label>
				<input type="checkbox" checked="true" id="visFooter" style="display: none;"/>
			</xsl:if>

			<div class="eh-section">
				<div class="eh-row-4">
					<div class="eh-col-1">
						<div class="eh-label">Melding opprettet</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='GenDate']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
					<xsl:if test="child::*[local-name()='IssueDate']">
						<div class="eh-col-1">
							<div class="eh-label">Melding utstedt</div>
							<div class="eh-field">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
				</div>
				<div class="eh-row-4">
					<div class="eh-col-1">
						<div class="eh-label">Visningsversjon</div>
						<div class="eh-field"><xsl:value-of select="$versjon"/></div>
					</div>
					<div class="eh-col-1">
						<div class="eh-label">Visningsstil</div>
						<div class="eh-field"><xsl:value-of select="$stil"/></div>
					</div>
					<xsl:if test="../child::*[local-name()='MsgVersion'] or ../child::*[local-name()='MIGversion']">
						<div class="eh-col-1">
							<div class="eh-label">Meldingsversjon</div>
							<div class="eh-field">
								<xsl:value-of select="../child::*[local-name()='Type']/@DN"/>
								<xsl:text>&#160;</xsl:text>
								<xsl:choose>
									<xsl:when test="../child::*[local-name()='MsgVersion']">
										<xsl:value-of select="../child::*[local-name()='MsgVersion']"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="../child::*[local-name()='MIGversion']"/>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</div>
					</xsl:if>
				</div>
				<div class="eh-row-4">
					<xsl:if test="../child::*[local-name()='Status']">
						<div class="eh-col-1">
							<div class="eh-label">Meldingsstatus</div>
							<div class="eh-field">
								<xsl:for-each select="../child::*[local-name()='Status']">
									<xsl:call-template name="k-8323"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
					<div class="eh-col-1">
						<div class="eh-label">Meldingsid</div>
						<div class="eh-field">
							<xsl:value-of select="../child::*[local-name()='MsgId']"/>
						</div>
					</div>
				</div>
			</div>
		</footer>
	</xsl:template>

	<xsl:template name="Bunn"> <!-- v2.0 -->
		<footer class="{$stil}">

			<h2>Dokumentinformasjon</h2>

			<xsl:if test="$VisDokInfoVisSkjul">
				<label for="visFooter" class="VisSkjul">Vis/Skjul</label>
				<input type="checkbox" checked="true" id="visFooter" style="display: none;"/>
			</xsl:if>

			<div class="eh-section">
				<div class="eh-row-4">
					<div class="eh-col-1">
						<div class="eh-label">Melding opprettet</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="//mh:GenDate"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
					<xsl:if test="//mh:IssueDate">
						<div class="eh-col-1">
							<div class="eh-label">Melding utstedt</div>
							<div class="eh-field">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="//mh:IssueDate"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
				</div>
				<div class="eh-row-4">
					<div class="eh-col-1">
						<div class="eh-label">Visningsversjon</div>
						<div class="eh-field"><xsl:value-of select="$versjon"/></div>
					</div>
					<div class="eh-col-1">
						<div class="eh-label">Visningsstil</div>
						<div class="eh-field"><xsl:value-of select="$stil"/></div>
					</div>
					<xsl:if test="//mh:MsgVersion or //mh:MIGversion">
						<div class="eh-col-1">
							<div class="eh-label">Meldingsversjon</div>
							<div class="eh-field">
								<xsl:value-of select="//mh:Type/@DN"/>
								<xsl:text>&#160;</xsl:text>
								<xsl:choose>
									<xsl:when test="//mh:MsgVersion">
										<xsl:value-of select="//mh:MsgVersion"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="//mh:MIGversion"/>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</div>
					</xsl:if>
				</div>
				<div class="eh-row-4">
					<xsl:if test="//mh:ProcessingStatus">
						<div class="eh-col-1">
							<div class="eh-label">Meldingsstatus</div>
							<div class="eh-field">
								<xsl:for-each select="//mh:ProcessingStatus">
									<xsl:call-template name="k-8113"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
					<div class="eh-col-1">
						<div class="eh-label">Meldingsid</div>
						<div class="eh-field">
							<xsl:value-of select="//mh:MsgId"/>
						</div>
					</div>
				</div>
			</div>
		</footer>
	</xsl:template>

	<xsl:template name="EgetBunnTillegg"></xsl:template> <!-- v1.0, v1.1 -->

	<!-- Klikkbar horisontal meny som leder lenger ned i dokumentet -->
	<xsl:template name="FellesMeny">
		<xsl:param name="position"/>
		<nav id="FellesMeny" class="FellesMeny NoPrint" style="padding-bottom: 1em;">
			<ul>
				<xsl:if test="//child::*[local-name()='Diagnosis'] or //child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='DIAG'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='H' or child::*[local-name()='Type']/@V='B']">
					<li>
						<xsl:variable name="temp10" select="concat('Diagnosis',$position)"/>
						<a href="#{$temp10}">Diagnoser</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='CAVE' or child::*[local-name()='Type']/@V='NB']">
					<li>
						<xsl:variable name="temp20" select="concat('CAVE',$position)"/>
						<a href="#{$temp20}">
							<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='CAVE']">Kritisk informasjon</xsl:if>
							<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='CAVE' and child::*[local-name()='Type']/@V='NB']">&#160;og&#160;</xsl:if>
							<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='NB']">NB-opplysninger</xsl:if>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='PROB'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='SYMP' or child::*[local-name()='Type']/@V='PROG' or child::*[local-name()='Type']/@V='SM']">
					<li>
						<xsl:variable name="temp30" select="concat('PROB',$position)"/>
						<a href="#{$temp30}">Aktuell problemstilling</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='ART']">
					<li>
						<xsl:variable name="temp35" select="concat('ART',$position)"/>
						<a href="#{$temp35}">Andre relevante tilstander</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='UTRED']">
					<li>
						<xsl:variable name="temp40" select="concat('UTRED',$position)"/>
						<a href="#{$temp40}">Forventet utredning/behandling</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='OPPL']">
					<li>
						<xsl:variable name="temp50" select="concat('OPPL',$position)"/>
						<a href="#{$temp50}">Kliniske opplysninger</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='GOPL' or child::*[local-name()='Type']/@V='GBEH']">
					<li>
						<xsl:variable name="temp60" select="concat('GOPL',$position)"/>
						<a href="#{$temp60}">Gynekologiske opplysninger</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='SVU']">
					<li>
						<xsl:variable name="temp70" select="concat('SVU',$position)"/>
						<a href="#{$temp70}">Spesialistvurdering</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='VU']">
					<li>
						<xsl:variable name="temp80" select="concat('VU',$position)"/>
						<a href="#{$temp80}">Vurdering</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='BG' or child::*[local-name()='Heading']/@V='BUP-BM' or child::*[local-name()='Heading']/@V='BUP-HG' or child::*[local-name()='Heading']/@V='KF' or child::*[local-name()='Heading']/@V='MAAL' or child::*[local-name()='Heading']/@V='MU' or child::*[local-name()='Heading']/@V='RU' or child::*[local-name()='Heading']/@V='UP' or not(child::*[local-name()='Heading'])]">
					<li>
						<xsl:variable name="temp90" select="concat('Annen',$position)"/>
						<a href="#{$temp90}">Annen begrunnelse</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='ANAM' or child::*[local-name()='Type']/@V='TB' or child::*[local-name()='Type']/@V='US']">
					<li>
						<xsl:variable name="temp100" select="concat('ANAM',$position)"/>
						<a href="#{$temp100}">Sykehistorie</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='FUNN'] or //child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='FU']">
					<li>
						<xsl:variable name="temp110" select="concat('ResultItem',$position)"/>
						<a href="#{$temp110}">Funn/undersøkelsesresultat</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='OPIN' or child::*[local-name()='Type']/@V='MPRS' or child::*[local-name()='Type']/@V='PRS']">
					<li>
						<xsl:variable name="temp120" select="concat('OPIN',$position)"/>
						<a href="#{$temp120}">Prosedyrer</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='FO']">
					<li>
						<xsl:variable name="temp130" select="concat('FO',$position)"/>
						<a href="#{$temp130}">Forløp og behandling</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='HJ']">
					<li>
						<xsl:variable name="temp140" select="concat('HJ',$position)"/>
						<a href="#{$temp140}">Funksjonsnivå/hjelpetiltak</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='MEDB']">
					<li>
						<xsl:variable name="temp150" select="concat('Medication',$position)"/>
						<a href="#{$temp150}">Legemiddelopplysninger</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='FA']">
					<li>
						<xsl:variable name="temp160" select="concat('FA',$position)"/>
						<a href="#{$temp160}">Familie/sosialt</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='IP']">
					<li>
						<xsl:variable name="temp170" select="concat('IP',$position)"/>
						<a href="#{$temp170}">Informasjon til pasient/pårørende</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='SYKM']">
					<li>
						<xsl:variable name="temp180" select="concat('SYKM',$position)"/>
						<a href="#{$temp180}">Sykemelding</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Pakkeforlop']">
					<li>
						<xsl:variable name="temp185" select="concat('Pakkeforlop',$position)"/>
						<a href="#{$temp185}">Pakkeforløp</a>
					</li>
				</xsl:if>
				<!-- <xsl:if test="//child::*[local-name()='ServReq']/child::*[local-name()='Comment']"> -->
				<xsl:if test="//child::*[local-name()='Comment']">
					<li>
						<xsl:variable name="temp190" select="concat('Comment',$position)"/>
						<a href="#{$temp190}">Kommentarer</a>
					</li>
				</xsl:if>

				<xsl:for-each select="//child::*[local-name()='Patient']">
				<!--
					<xsl:if test="child::*[local-name()='BasisForHealthServices'] or child::*[local-name()='Sex'] or child::*[local-name()='DateOfBirth'] or child::*[local-name()='PatientPrecaution'] or child::*[local-name()='AssistertKommunikasjon'] or child::*[local-name()='ParorendeForesatt'] or child::*[local-name()='ContactPerson'] or child::*[local-name()='PatRelInst'] or child::*[local-name()='Consent'] or child::*[local-name()='AdditionalId'] or child::*[local-name()='NeedTranslator'] or child::*[local-name()='CareSituation']">
						<li>
							<xsl:variable name="temp200" select="concat('Patient',$position)"/>
							<a href="#{$temp200}">Pasient</a>
						</li>
					</xsl:if>
				-->
					<xsl:if test="child::*[local-name()='PatRelHCP']">
						<li>
							<xsl:variable name="temp210" select="concat('PatRelHCP',$position)"/>
							<a href="#{$temp210}">Kontaktopplysninger</a>
						</li>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="child::*[local-name()='PatientPrecaution'] or child::*[local-name()='BasisForHealthServices'] or child::*[local-name()='TilleggsopplysningPasient'] or child::*[local-name()='Consent'] or child::*[local-name()='ParorendeForesatt'] or child::*[local-name()='InfoAssistertKommunikasjon'] or child::*[local-name()='PasientrelatertKontaktperson']">
					<li>
						<xsl:variable name="temp220" select="concat('PatientInformation',$position)"/>
						<a href="#{$temp220}">Pasientopplysninger</a>
					</li>
				</xsl:if>
				<xsl:if test="child::*[local-name()='OpplysningerOmIndividuellPlan']">
					<li>
						<a href="#OpplysningerOmIndividuellPlan">Opplysninger&#160;om&#160;individuell&#160;plan</a>
					</li>
				</xsl:if>
				<xsl:if test="child::*[local-name()='TilknyttetEnhet'] or child::*[local-name()='KontaktpersonHelsepersonell'] or child::*[local-name()='AnsvarForRapport']">
					<li>
						<xsl:variable name="temp230" select="concat('PatRelHCP',$position)"/>
						<a href="#{$temp230}">Kontaktopplysninger</a>
					</li>
				</xsl:if>
				<xsl:if test="child::*[local-name()='VurderingAvHenvisning']">
					<li>
						<xsl:variable name="temp240" select="concat('vurderingHenvisning',$position)"/>
						<a href="#{$temp240}">Rettighetsvurdering</a>
					</li>
				</xsl:if>
				<xsl:if test="child::*[local-name()='RefDoc'] or count(//child::*[local-name()='RefDoc']) &gt; 1">
					<li>
						<xsl:variable name="temp250" select="concat('RefDoc',$position)"/>
						<a href="#{$temp250}">Vedlegg</a>
					</li>
				</xsl:if>
			</ul>
		</nav>
	</xsl:template>

	<xsl:template name="Diagnosis">
		<div  class="eh-row-4">
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:value-of select="child::*[local-name()='Concept']/@V"/>&#160;
					<xsl:if test="contains(child::*[local-name()='Concept']/@S, '7170')">(ICPC)</xsl:if>
					<xsl:if test="contains(child::*[local-name()='Concept']/@S, '7110')">(ICD-10)</xsl:if>
				</div>
				<div class="eh-field">
					<xsl:if test="child::*[local-name()='Concept']/@DN or child::*[local-name()='Concept']/@OT">
						<xsl:for-each select="child::*[local-name()='Concept']">
							<xsl:call-template name="k-dummy"/>
						</xsl:for-each>
					</xsl:if>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='Modifier']"> <!-- maxOccurs="unbounded" -->
				<div class="eh-col-3 eh-last-child">
					<xsl:for-each select="child::*[local-name()='Modifier']/child::*[local-name()='Name']">
						<div class="eh-label"><xsl:call-template name="k-7305"/></div>
						<div class="eh-field">
							&#160;<xsl:value-of select="../child::*[local-name()='Value']/@V"/>&#160;-&#160;<xsl:value-of select="../child::*[local-name()='Value']/@DN"/>
						</div>
						<br/>
					</xsl:for-each>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Deprecated: erstattet av felleskomponenter/eh_komponent1.xsl : eh-ReasonAsText -->
	<xsl:template name="ReasonAsText"> <!-- maxOccurs="unbounded" -->

		<div  class="eh-row-4">
			<xsl:choose>
				<xsl:when test="child::*[local-name()='Heading']/@V='BG' or  child::*[local-name()='Heading']/@V='BUP-BM' or child::*[local-name()='Heading']/@V='BUP-HG' or child::*[local-name()='Heading']/@V='KF' or child::*[local-name()='Heading']/@V='MAAL' or child::*[local-name()='Heading']/@V='MU' or child::*[local-name()='Heading']/@V='RU' or child::*[local-name()='Heading']/@V='UP'">
					<div class="eh-col-1 eh-label">
						<xsl:call-template name="k-8231"/>
						<xsl:if test="not(child::*[local-name()='Heading'])">Begrunnelse (uspes.)</xsl:if>
					</div>
				</xsl:when>
				<xsl:when test="not(child::*[local-name()='Heading'])">
					<div class="eh-col-1 eh-label">Begrunnelse (uspes.)</div>
				</xsl:when>
			</xsl:choose>

			<div class="eh-col-1 eh-field eh-last-child">

				<xsl:if test="child::*[local-name()='TextResultValue']">
					<div>
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='TextResultValue']"/>
						</xsl:call-template>
					</div>
				</xsl:if>
				<xsl:for-each select="child::*[local-name()='TextCode'] | child::*[local-name()='TextCode']"> <!-- maxOccurs="unbounded" -->
					<xsl:if test="position() &gt; 1">
						<br/>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="@DN">
							<xsl:value-of select="@DN"/>&#160;</xsl:when>
						<xsl:when test="@OT">
							<xsl:value-of select="@OT"/>&#160;</xsl:when>
						<xsl:when test="@V">
							<xsl:value-of select="@V"/>&#160;<xsl:choose>
								<xsl:when test="contains(@S,'7010')">(SNOMED)</xsl:when>
								<xsl:when test="contains(@S,'7230')">(NKKKL)</xsl:when>
								<xsl:when test="contains(@S,'7240')">(NORAKO)</xsl:when>
							</xsl:choose>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>

			</div>

		</div>
	</xsl:template>

	<!-- Deprecated: erstattet av felleskomponenter/eh-komponent1.xsl : eh-Observation -->
	<xsl:template name="Observation"> <!-- ServRec/Patient/InfItem/Observation -->
		<div class="eh-row-4">
			<xsl:variable name="cssClass">
				<xsl:choose>
					<xsl:when test="../child::*[local-name()='StartDateTime'] | ../child::*[local-name()='EndDateTime'] | ../child::*[local-name()='OrgDate']">
					</xsl:when>
					<xsl:otherwise>eh-last-child</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<div class="eh-col-1 {$cssClass}" >
				<div class="eh-field">
					<xsl:if test="child::*[local-name()='Description']">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Description']"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="child::*[local-name()='Description'] and child::*[local-name()='Comment']">
						<br/>
					</xsl:if>
					<xsl:if test="child::*[local-name()='Comment']">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Comment']"/>
						</xsl:call-template>
					</xsl:if>
				</div>
			</div>

			<xsl:if test="../child::*[local-name()='StartDateTime'] | ../child::*[local-name()='EndDateTime'] | ../child::*[local-name()='OrgDate']">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-field">
						<xsl:if test="../child::*[local-name()='StartDateTime']">
							Start:&#160;<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='StartDateTime']"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="../child::*[local-name()='EndDateTime']">
							<xsl:if test="../child::*[local-name()='StartDateTime']">
								<br/>
							</xsl:if>
							Slutt:&#160;<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="../child::*[local-name()='EndDateTime']"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
						</xsl:if>
						<xsl:if test="../child::*[local-name()='OrgDate']">
							<xsl:if test="../child::*[local-name()='StartDateTime'] or ../child::*[local-name()='EndDateTime']">
								<br/>
							</xsl:if>
							Opprinnelse:&#160;<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="../child::*[local-name()='OrgDate']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
						</xsl:if>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Deprecated: erstattet av felleskomponenter/eh-komponent1.xsl : template eh-resultItem -->
	<xsl:template name="ResultItem"> <!-- merk: rad-element ikke inkludert her. Max 6 columns -->
		<div class="eh-col-1 eh-field">
			<xsl:for-each select="child::*[local-name()='ClinInv']">
				<xsl:for-each select="child::*[local-name()='Id']"> 	<!-- minOccurs="1" -->
					<xsl:call-template name="k-dummy"/>
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='Spec']"> 	<!-- maxOccurs="unbounded" -->
					<br/>
					<b>Spesifisert:</b>&#160;
					<xsl:call-template name="k-dummy"/>
				</xsl:for-each>
			</xsl:for-each>
		</div>

		<div class="eh-col-1 eh-field">
			<xsl:for-each select="child::*[local-name()='Interval']">
				<xsl:if test="child::*[local-name()='Low']">
					<b>Nedre:</b>&#160;<xsl:value-of select="child::*[local-name()='Low']/@V"/>
					<xsl:value-of select="child::*[local-name()='Low']/@U"/>&#160;
				</xsl:if>
				<xsl:if test="child::*[local-name()='High']">
					<b>Øvre:</b>&#160;<xsl:value-of select="child::*[local-name()='High']/@V"/>
					<xsl:value-of select="child::*[local-name()='High']/@U"/>&#160;
				</xsl:if>
			</xsl:for-each>

			<xsl:for-each select="child::*[local-name()='DateResult']">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateResultValue']/@V"/>
					<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
				</xsl:call-template>
			</xsl:for-each>

			<xsl:for-each select="child::*[local-name()='NumResult']">
				<xsl:for-each select="child::*[local-name()='ArithmeticComp']">
					<xsl:call-template name="k-8239"/>
				</xsl:for-each>
				<xsl:value-of select="child::*[local-name()='NumResultValue']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='NumResultValue']/@U"/>&#160;
				<xsl:for-each select="../child::*[local-name()='DevResultInd']">
					<b style="color:red;">
						<xsl:call-template name="k-8244"/>
					</b>
				</xsl:for-each>
			</xsl:for-each>

			<xsl:for-each select="child::*[local-name()='TextResult']/child::*[local-name()='Result']">
				<xsl:if test="child::*[local-name()='TextResultValue']">
					<div>
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='TextResultValue']"/>
						</xsl:call-template>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='TextCode']">
					<div>
						<xsl:call-template name="k-dummy"/>
					</div>
				</xsl:if>
			</xsl:for-each>

			<xsl:if test="child::*[local-name()='Comment']">
				<div>
					<b>Kommentar:</b>&#160;<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="child::*[local-name()='Comment']"/>
					</xsl:call-template>
				</div>
			</xsl:if>
		</div>

		<xsl:if test="//child::*[local-name()='ResultItem']/child::*[local-name()='InvDate']">
			<div class="eh-col-1 eh-field">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="child::*[local-name()='InvDate']/@V"/>
					<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
				</xsl:call-template>
			</div>
		</xsl:if>


		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='StartDateTime']"> <!-- up one level : InfItem -->
			<div class="eh-col-1 eh-field">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../child::*[local-name()='StartDateTime']"/>
					<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
				</xsl:call-template>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='EndDateTime']"> <!-- up one level : InfItem -->
			<div class="eh-col-1 eh-field">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../child::*[local-name()='EndDateTime'] | ../child::*[local-name()='EndDateTime']"/>
					<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
				</xsl:call-template>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='OrgDate']"> <!-- up one level : InfItem -->
			<div class="eh-col-1 eh-field">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../child::*[local-name()='OrgDate']/@V"/>
					<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
				</xsl:call-template>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Deprecated: erstattet av felleskomponenter/eh-komponent1.xsl : eh-Medication -->
	<xsl:template name="Medication"> <!-- merk: rad-element ikke inkludert her. -->
		<div class="eh-col-1 eh-field">
			<xsl:for-each select="child::*[local-name()='DrugId']">
				<xsl:call-template name="k-dummy"/>
			</xsl:for-each>
		</div>

		<div class="eh-col-1 eh-field">
			<xsl:for-each select="child::*[local-name()='Status']">
				<xsl:call-template name="k-7307"/>
			</xsl:for-each>
		</div>

		<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='UnitDose'] or //child::*[local-name()='Medication']/child::*[local-name()='QuantitySupplied']">
			<div class="eh-col-1 eh-field">
				<xsl:if test="child::*[local-name()='UnitDose']">
					<xsl:value-of select="child::*[local-name()='UnitDose']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='UnitDose']/@U "/>
					<xsl:if test="child::*[local-name()='QuantitySupplied']">&#160;x&#160;</xsl:if>
				</xsl:if>
				<xsl:if test="child::*[local-name()='QuantitySupplied']">
					<xsl:value-of select="child::*[local-name()='QuantitySupplied']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='QuantitySupplied']/@U"/>
				</xsl:if>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='DosageText'] or //child::*[local-name()='Medication']/child::*[local-name()='IntendedDuration']">
			<div class="eh-col-1 eh-field">
				<xsl:if test="child::*[local-name()='DosageText']">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="child::*[local-name()='DosageText']"/>
					</xsl:call-template>
				</xsl:if>&#160;
				<xsl:if test="child::*[local-name()='IntendedDuration']">&#160;/&#160;<xsl:value-of select="child::*[local-name()='IntendedDuration']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='IntendedDuration']/@U"/>
				</xsl:if>
				<xsl:if test="not(child::*[local-name()='DosageText']) and not(child::*[local-name()='IntendedDuration'])">&#160;</xsl:if>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='Comment']">
			<div class="eh-col-1 eh-field">
				<xsl:call-template name="line-breaks">
					<xsl:with-param name="text" select="child::*[local-name()='Comment']"/>
				</xsl:call-template>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Medication']]/child::*[local-name()='StartDateTime']">
			<div class="eh-col-1 eh-field">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../child::*[local-name()='StartDateTime']/@V "/>
					<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
				</xsl:call-template>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Medication']]/child::*[local-name()='EndDateTime']">
			<div class="eh-col-1 eh-field">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../child::*[local-name()='EndDateTime']/@V"/>
					<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
				</xsl:call-template>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Medication']]/child::*[local-name()='OrgDate']">
			<div class="eh-col-1 eh-field">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../child::*[local-name()='OrgDate']/@V"/>
					<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
				</xsl:call-template>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="PatientInformation"> <!-- Document/RefDoc/Content/Henvisning (v2.0) -->
		<xsl:if test="child::*[local-name()='PatientPrecaution']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label" style="color: red;">Advarsel</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='PatientPrecaution']"> <!-- maxOccurs="unbounded" -->
							<xsl:value-of select="child::*[local-name()='Precaution']"/>
							<xsl:if test="child::*[local-name()='StartDateTime'] or child::*[local-name()='EndDateTime']">
								<xsl:choose>
									<xsl:when test="child::*[local-name()='StartDateTime']/@V or child::*[local-name()='EndDateTime']/@V"> <!-- kith:TS -->
										(<xsl:if test="child::*[local-name()='StartDateTime']"><xsl:call-template name="skrivUtTS"><xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']/@V"/><xsl:with-param name="useNormalSpaceSeparator" select="true()"/></xsl:call-template></xsl:if>&#160;-&#160;<xsl:if test="child::*[local-name()='EndDateTime']"><xsl:call-template name="skrivUtTS"><xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']/@V"/></xsl:call-template></xsl:if>)
									</xsl:when>
									<xsl:otherwise> <!-- dateTime, date, etc. -->
										(<xsl:if test="child::*[local-name()='StartDateTime']"><xsl:call-template name="skrivUtTS"><xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']"/><xsl:with-param name="useNormalSpaceSeparator" select="true()"/></xsl:call-template></xsl:if>&#160;-&#160;<xsl:if test="child::*[local-name()='EndDateTime']"><xsl:call-template name="skrivUtDateTime"><xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']"/></xsl:call-template></xsl:if>)
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="position()!=last()">,&#160;</xsl:if>
						</xsl:for-each>
					</div>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='BasisForHealthServices'] or child::*[local-name()='TilleggsopplysningPasient'] or child::*[local-name()='Consent']">
			<div class="eh-row-4">

				<xsl:if test="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='BorAlene']">
					<div class="eh-col-1">
						<div class="eh-label">Bostatus</div>
						<div class="eh-field">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='BorAlene']='true'">Bor alene</xsl:when>
								<xsl:otherwise>Bor ikke alene</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>

				<xsl:if test="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='SivilStatus']">
					<div class="eh-col-1">
						<div class="eh-label">Sivilstatus</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='SivilStatus']">
								<xsl:call-template name="k-8724"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>

				<xsl:if test="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='Sprak']">
					<div class="eh-col-1">
						<div class="eh-label">Spr&#229;k</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='Sprak']">
								<xsl:call-template name="k-3303"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>

				<xsl:if test="child::*[local-name()='BasisForHealthServices']">
					<div class="eh-col-1">
						<div class="eh-label">Refusjonsgrunnlag</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='BasisForHealthServices']">
								<xsl:call-template name="k-8246"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>

				<xsl:if test="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='MottarKommunaleTjenester']">
					<div class="eh-col-1">
						<div class="eh-label">Mottar kommunale tjenester</div>
						<div class="eh-field">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='MottarKommunaleTjenester']='true'">Ja</xsl:when>
								<xsl:otherwise>Nei</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>

				<xsl:if test="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='Merknad']">
					<div class="eh-col-1">
						<div class="eh-label">Merknad</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='Merknad']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>

			</div>
			<xsl:for-each select="child::*[local-name()='Consent']">
				<div class="eh-row-4">
					<div class="eh-col-1">
						<div class="eh-label">Samtykke gitt</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='ConsentStatus']">
								<xsl:choose>
									<xsl:when test="contains(@V,'9064')"><xsl:call-template name="k-9064"/></xsl:when>
									<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</div>
					</div>
					<!--Dato samtykke ble gitt-->
					<xsl:if test="child::*[local-name()='ConsentDate']">
						<div class="eh-col-1">
							<div class="eh-label">Dato gitt</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='ConsentDate']">
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="."/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
					<!--Samtykke gitt av-->
					<xsl:if test="child::*[local-name()='GivenBy']">
						<div class="eh-col-1">
							<div class="eh-label">Samtykke gitt av</div>
							<div class="eh-field">
								<xsl:value-of select="child::*[local-name()='GivenBy']"/>
							</div>
						</div>
					</xsl:if>
					<!--Merknad-->
					<xsl:if test="child::*[local-name()='Merknad']">
						<div class="eh-col-1 eh-last-child">
							<div class="eh-label">Merknad</div>
							<div class="eh-field">
								<xsl:value-of select="child::*[local-name()='Merknad']"/>
							</div>
						</div>
					</xsl:if>
				</div>
			</xsl:for-each>
		</xsl:if>
		<xsl:for-each select="child::*[local-name()='ParorendeForesatt']">
			<div class="eh-row-4">
				<div class="eh-col-1">
					<div class="eh-label">
						<xsl:for-each select="child::*[local-name()='Slektskap']">
							<xsl:call-template name="k-9033"/>&#160;
							<xsl:if test="../child::*[local-name()='Omsorgsfunksjon']">og&#160;</xsl:if>
						</xsl:for-each>
						<xsl:for-each select="child::*[local-name()='Omsorgsfunksjon']">
							<xsl:call-template name="k-9050"/>&#160;
						</xsl:for-each>
						<xsl:if test="not(child::*[local-name()='Slektskap']) and not(child::*[local-name()='Omsorgsfunksjon'])">Pårørende/foresatt</xsl:if>
					</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Referanseperson']">
							<xsl:call-template name="Person"/>
						</xsl:for-each>
					</div>
				</div>
				<xsl:if test="child::*[local-name()='FodselsarMindrearigParorende']">
					<div class="eh-col-1">
						<div class="eh-label">Født</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='FodselsarMindrearigParorende']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='NarmesteParorende']">
					<div class="eh-col-1">
						<div class="eh-label">Nærmeste pårørende</div>
						<div class="eh-field">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='NarmesteParorende']='true'">Ja</xsl:when>
								<xsl:otherwise>Nei</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Merknad']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Merknad</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='InfoAssistertKommunikasjon']/child::*[local-name()='AssistertKommunikasjon']">
		    <div class="eh-row-4">
				<div  class="eh-col-4">
					<div class="eh-label">Assistert kommunikasjon</div>
				</div>
		    </div>
		    <div class="eh-row-4">
				<xsl:if test="child::*[local-name()='PersonTolkebehov']">
					<div class="eh-col-1">
						<div class="eh-label">Gjelder&#160;for</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='PersonTolkebehov']">
								<xsl:call-template name="Person"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='BehovTolkSprak']">
					<div class="eh-col-1">
						<div class="eh-label">Behov for tolk - Språk</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='BehovTolkSprak']">
								<xsl:call-template name="k-3303"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='PreferertTolk']">
					<div class="eh-col-1">
						<div class="eh-label">Ønsket&#160;tolk</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='PreferertTolk']">
								<xsl:call-template name="Person"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Horselsvikt'] or child::*[local-name()='Synsvikt'] or child::*[local-name()='BehovOpphortDato'] or child::*[local-name()='Merknad']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Merknad</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
							</xsl:call-template>
							<xsl:if test="child::*[local-name()='Horselsvikt']='true' or child::*[local-name()='Synsvikt']='true' or child::*[local-name()='BehovOpphortDato']">
								<div>
									<xsl:if test="child::*[local-name()='Horselsvikt']='true'">
										<b>Hørselsvikt:</b>&#160;Ja&#160;
									</xsl:if>
									<xsl:if test="child::*[local-name()='Synsvikt']='true'">
										<b>Synsvikt:</b>&#160;Ja&#160;
									</xsl:if>
								</div>
								<div>
									<xsl:if test="child::*[local-name()='BehovOpphortDato']">
										<b>Behov&#160;for&#160;tolk&#160;opphørte:</b>&#160;
										<xsl:value-of select="child::*[local-name()='BehovOpphortDato']"/>
									</xsl:if>
								</div>
							</xsl:if>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='PasientrelatertKontaktperson']">
			<div class="eh-row-4">
				<div  class="eh-col-4">
					<div class="eh-label">Pasientrelatert kontaktperson</div>
				</div>
		    </div>
			<div class="eh-row-4">
				<div class="eh-col-1">
					<div class="eh-label">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='StillingRolle']">
								<xsl:value-of select="child::*[local-name()='StillingRolle']"/>
							</xsl:when>
							<xsl:otherwise>Referanseperson</xsl:otherwise>
						</xsl:choose>
					</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Referanseperson']">
							<xsl:call-template name="Person"/>
						</xsl:for-each>
					</div>
				</div>
				<xsl:if test="child::*[local-name()='Arbeidssted']">
					<div class="eh-col-1">
						<div class="eh-label">Arbeidssted</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Arbeidssted']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Merknad']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Merknad</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="PatientInformation_test"> <!-- Document/RefDoc/Content/Henvisning (v2.0) -->
		<xsl:if test="child::*[local-name()='PatientPrecaution']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label" style="color: red;">Advarsel</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='PatientPrecaution']"> <!-- maxOccurs="unbounded" -->
							<xsl:value-of select="child::*[local-name()='Precaution']"/>
							<xsl:if test="child::*[local-name()='StartDateTime'] or child::*[local-name()='EndDateTime']">
								(<xsl:if test="child::*[local-name()='StartDateTime']"><xsl:call-template name="skrivUtTS"><xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']/@V"/><xsl:with-param name="useNormalSpaceSeparator" select="true()"/></xsl:call-template></xsl:if>&#160;-&#160;<xsl:if test="child::*[local-name()='EndDateTime']"><xsl:call-template name="skrivUtTS"><xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']/@V"/></xsl:call-template></xsl:if>)
							</xsl:if>
							<xsl:if test="position()!=last()">,&#160;</xsl:if>
						</xsl:for-each>
					</div>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='BasisForHealthServices'] or child::*[local-name()='TilleggsopplysningPasient'] or child::*[local-name()='Consent']">
			<div class="eh-row-4">
				<xsl:if test="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='SivilStatus'] or child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='BorAlene']">
					<div class="eh-col-1">
						<div class="eh-label">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='BorAlene'] and not(child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='SivilStatus'])">Bostatus</xsl:when>
								<xsl:when test="not(child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='BorAlene']) and child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='SivilStatus']">Sivilstatus</xsl:when>
								<xsl:otherwise>Bo-&#160;/&#160;sivilstatus</xsl:otherwise>
							</xsl:choose>
						</div>
						<div class="eh-field">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='BorAlene']='true'">Bor alene</xsl:when>
								<xsl:otherwise>Bor ikke alene</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='SivilStatus']">,&#160;</xsl:if>
							<xsl:for-each select="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='SivilStatus']">
								<xsl:call-template name="k-8724"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='Sprak']">
					<div class="eh-col-1">
						<div class="eh-label">Språk</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='TilleggsopplysningPasient']/child::*[local-name()='Sprak']">
								<xsl:call-template name="k-3303"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='BasisForHealthServices']">
					<div class="eh-col-1">
						<div class="eh-label">Refusjonsgrunnlag</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='BasisForHealthServices']">
								<xsl:call-template name="k-8246"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Consent']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Samtykke gitt</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Consent']">
								<xsl:choose>
									<xsl:when test="contains(@S,'3109')"><xsl:call-template name="k-3109"/></xsl:when>
									<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:for-each select="child::*[local-name()='ParorendeForesatt']">
			<div class="eh-row-4">
				<div class="eh-col-1">
					<div class="eh-label">
						<xsl:for-each select="child::*[local-name()='Slektskap']">
							<xsl:call-template name="k-9033"/>&#160;
							<xsl:if test="../child::*[local-name()='Omsorgsfunksjon']">og&#160;</xsl:if>
						</xsl:for-each>
						<xsl:for-each select="child::*[local-name()='Omsorgsfunksjon']">
							<xsl:call-template name="k-9050"/>&#160;
						</xsl:for-each>
						<xsl:if test="not(child::*[local-name()='Slektskap']) and not(child::*[local-name()='Omsorgsfunksjon'])">Pårørende/foresatt</xsl:if>
					</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Referanseperson']">
							<xsl:call-template name="Person"/>
						</xsl:for-each>
					</div>
				</div>
				<xsl:if test="child::*[local-name()='FodselsarMindrearigParorende']">
					<div class="eh-col-1">
						<div class="eh-label">Født</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='FodselsarMindrearigParorende']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Merknad']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Merknad</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='InfoAssistertKommunikasjon']/child::*[local-name()='AssistertKommunikasjon']">
			<div class="eh-row-4">
				<div class="eh-label">Assistert kommunikasjon:</div>
				<xsl:if test="child::*[local-name()='PersonTolkebehov']">
					<div class="eh-col-1">
						<div class="eh-label">Gjelder&#160;for</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='PersonTolkebehov']">
								<xsl:call-template name="Person"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='BehovTolkSprak']">
					<div class="eh-col-1">
						<div class="eh-label">Behov for tolk - Språk</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='BehovTolkSprak']">
								<xsl:call-template name="k-3303"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='PreferertTolk']">
					<div class="eh-col-1">
						<div class="eh-label">Ønsket&#160;tolk</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='PreferertTolk']">
								<xsl:call-template name="Person"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Horselsvikt'] or child::*[local-name()='Synsvikt'] or child::*[local-name()='BehovOpphortDato'] or child::*[local-name()='Merknad']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Merknad</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
							</xsl:call-template>
							<xsl:if test="child::*[local-name()='Horselsvikt']='true' or child::*[local-name()='Synsvikt']='true' or child::*[local-name()='BehovOpphortDato']">
								<div>
									<xsl:if test="child::*[local-name()='Horselsvikt']='true'">
										<b>Hørselsvikt:</b>&#160;Ja&#160;
									</xsl:if>
									<xsl:if test="child::*[local-name()='Synsvikt']='true'">
										<b>Synsvikt:</b>&#160;Ja&#160;
									</xsl:if>
								</div>
								<div>
									<xsl:if test="child::*[local-name()='BehovOpphortDato']">
										<b>Behov&#160;for&#160;tolk&#160;opphørte:</b>&#160;
										<xsl:value-of select="child::*[local-name()='BehovOpphortDato']"/>
									</xsl:if>
								</div>
							</xsl:if>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='PasientrelatertKontaktperson']">
			<div class="eh-row-4">
				<div  class="eh-col-4">
					<div class="eh-label">Pasientrelatert kontaktperson</div>
				</div>
		    </div>
			<div class="eh-row-4">
				<div class="eh-col-1">
					<div class="eh-label">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='StillingRolle']">
								<xsl:value-of select="child::*[local-name()='StillingRolle']"/>
							</xsl:when>
							<xsl:otherwise>Referanseperson</xsl:otherwise>
						</xsl:choose>
					</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Referanseperson']">
							<xsl:call-template name="Person"/>
						</xsl:for-each>
					</div>
				</div>
				<xsl:if test="child::*[local-name()='Arbeidssted']">
					<div class="eh-col-1">
						<div class="eh-label">Arbeidssted</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Arbeidssted']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Merknad']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Merknad</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="Patient_v1"> <!-- Message/ServReq/Patient (v1.0, v1.1) -->

		<xsl:if test="child::*[local-name()='BasisForHealthServices'] or child::*[local-name()='Sex'] or child::*[local-name()='DateOfBirth'] or child::*[local-name()='AdditionalId']">
			<div class="eh-row-8">
				<div class="eh-col-1 eh-label">Pasient&#173;info</div>
				<xsl:if test="child::*[local-name()='Name']">
					<div class="eh-col-1 md eh-label">Navn</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='OffId']">
					<div class="eh-col-1 md eh-label">
							<xsl:for-each select="child::*[local-name()='TypeOffId']">
								<xsl:call-template name="k-8116"/>
							</xsl:for-each>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Sex']">
					<div class="eh-col-1 md eh-label">Kjønn</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='DateOfBirth']">
					<div class="eh-col-1 md eh-label">Fødsels&#173;dag</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='DateOfDeath']">
					<div class="eh-col-1 md eh-label">Dødsdag</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='BasisForHealthServices']">
					<div class="eh-col-1 md eh-label">Refusjons&#173;grunnlag</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='AdditionalId']">
					<div class="eh-col-1 md eh-last-child eh-label">Tilleggs-Id</div>
				</xsl:if>
			</div>
			<div class="eh-row-8">
				<div class="eh-col-1 md eh-label">&#160;</div>
				<xsl:if test="child::*[local-name()='Name']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Navn</div>
						<div class="eh-text">
							<xsl:value-of select="child::*[local-name()='Name']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='OffId']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">
							<xsl:for-each select="child::*[local-name()='TypeOffId']">
								<xsl:call-template name="k-8116"/>
							</xsl:for-each>
						</div>
						<div class="eh-text">
							<xsl:value-of select="child::*[local-name()='OffId']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Sex']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Kjønn</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='Sex']">
								<xsl:call-template name="k-3101"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='DateOfBirth']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Fødselsdag</div>
						<div class="eh-text">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateOfBirth']"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='DateOfDeath']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Dødsdag</div>
						<div class="eh-text">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateOfDeath']"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='BasisForHealthServices']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Refusjonsgrunnlag</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='BasisForHealthServices']">
								<xsl:call-template name="k-8246"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='AdditionalId']">
					<div class="eh-col-1 eh-field eh-last-child">
						<div class="eh-label xs">Tilleggs-Id</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='AdditionalId']">
								<div>
									<xsl:if test="child::*[local-name()='Type']">
										<b>
											<xsl:value-of select="child::*[local-name()='Type']/@V"/>:
										</b>
									</xsl:if>
									<xsl:value-of select="child::*[local-name()='Id']"/>
								</div>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>

		<xsl:for-each select="child::*[local-name()='PatientPrecaution']">
			<xsl:if test="position()=1">
				<div class="eh-row-8 md">
					<div class="eh-col-1 eh-last-child">
						<hr/>
					</div>
				</div>
				<div class="eh-row-8">
					<div class="eh-col-1 eh-label">Advarsel til tjenesteyter</div>
					<xsl:if test="..//child::*[local-name()='PatientPrecaution']/child::*[local-name()='Precaution']">
						<div class="eh-col-1 md eh-label">Advarsel</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatientPrecaution']/child::*[local-name()='StartDateTime']">
						<div class="eh-col-1 md eh-label">Start&#173;tidspunkt</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatientPrecaution']/child::*[local-name()='EndDateTime']">
						<div class="eh-col-1 md eh-label">Slut&#173;tidspunkt</div>
					</xsl:if>
				</div>
			</xsl:if>
			<div class="eh-row-8">
				<div class="eh-col-1 md eh-label">&#160;</div>
				<xsl:if test="..//child::*[local-name()='PatientPrecaution']/child::*[local-name()='Precaution']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Advarsel</div>
						<div class="eh-text">
							<xsl:value-of select="child::*[local-name()='Precaution']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatientPrecaution']/child::*[local-name()='StartDateTime']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Starttidspunkt</div>
						<div class="eh-text">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='StartDateTime']/@V"> <!-- kith:TS -->
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise> <!-- dateTime, date etc. -->
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatientPrecaution']/child::*[local-name()='EndDateTime']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Sluttidspunkt</div>
						<div class="eh-text">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='EndDateTime']/@V"> <!-- kith:TS -->
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise> <!-- dateTime, date etc. -->
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>

		<xsl:for-each select="child::*[local-name()='Consent']"> <!-- maxOccurs="1" -->
			<div class="eh-row-8 md">
				<div class="eh-col-1 eh-last-child">
					<hr/>
				</div>
			</div>
			<div class="eh-row-8">
				<div class="eh-col-1 eh-label">Samtykke</div>
				<xsl:if test="child::*[local-name()='ConsentStatus']">
					<div class="eh-col-1 md eh-label">Samtykke gitt</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='ConsentDate']">
					<div class="eh-col-1 md eh-label">Samtykkedato</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Merknad']">
					<div class="eh-col-1 md eh-label">Merknad</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='GivenBy']">
					<div class="eh-col-1 md eh-label eh-last-child">Gitt av</div>
				</xsl:if>
			</div>
			<div class="eh-row-8">
				<div class="eh-col-1 md eh-label">&#160;</div>
				<xsl:if test="child::*[local-name()='ConsentStatus']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Samtykke gitt</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='ConsentStatus']">
								<xsl:call-template name="k-3109"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='ConsentDate']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Samtykkedato</div>
						<div class="eh-text">
							<xsl:call-template name="skrivUtDate">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='ConsentDate']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Merknad']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Merknad</div>
						<div class="eh-text">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='GivenBy']">
					<div class="eh-col-1 eh-field eh-last-child">
						<div class="eh-label xs">Gitt av</div>
						<div class="eh-text"><xsl:value-of select="child::*[local-name()='GivenBy']"/></div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>

		<xsl:for-each select="child::*[local-name()='AssistertKommunikasjon']"> <!-- v1.1, maxOccurs="unbounded" -->
			<xsl:if test="position()=1">
				<div class="eh-row-8 md">
					<div class="eh-col-1 eh-last-child">
						<hr/>
					</div>
				</div>
			</xsl:if>
			<xsl:call-template name="eh-AssistertKommunikasjon" />
		</xsl:for-each>

		<xsl:for-each select="child::*[local-name()='ParorendeForesatt']"> <!-- maxOccurs="unbounded" -->
			<xsl:if test="position()=1">
				<div class="eh-row-8 md">
					<div class="eh-col-1 eh-last-child" style="width: 100%;">
						<hr/>
					</div>
				</div>
				<div class="eh-row-8">
					<div class="eh-col-1 eh-label">Pårørende/&#173;foresatt</div>
					<xsl:if test="..//child::*[local-name()='ParorendeForesatt']/child::*[local-name()='Referanseperson']">
						<div class="eh-col-1 md eh-label">Person</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='ParorendeForesatt']/child::*[local-name()='Slektskap']">
						<div class="eh-col-1 md eh-label">Slektskap</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='ParorendeForesatt']/child::*[local-name()='Omsorgsfunksjon']">
						<div class="eh-col-1 md eh-label">Omsorgsfunksjon</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='ParorendeForesatt']/child::*[local-name()='Merknad']">
						<div class="eh-col-1 md eh-label eh-last-child">Merknad</div>
					</xsl:if>
				</div>
			</xsl:if>
			<div class="eh-row-8">
				<div class="eh-col-1 md eh-label">&#160;</div>
				<xsl:if test="..//child::*[local-name()='ParorendeForesatt']/child::*[local-name()='Referanseperson']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Person</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='Referanseperson']">
								<div>
									<xsl:value-of select="fk1:FamilyName"/>,&#160;<xsl:value-of select="fk1:GivenName"/>&#160;<xsl:value-of select="fk1:MiddleName"/>
								</div>
								<xsl:for-each select=".//fk1:TeleAddress">
									<xsl:call-template name="eh-TeleAddressHode"/>
								</xsl:for-each>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='ParorendeForesatt']/child::*[local-name()='Slektskap']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Slektskap</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='Slektskap']">
								<xsl:call-template name="k-9033"/>&#160;
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='ParorendeForesatt']/child::*[local-name()='Omsorgsfunksjon']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Omsorgsfunksjon</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='Omsorgsfunksjon']">
								<xsl:call-template name="k-9050"/>&#160;
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='ParorendeForesatt']/child::*[local-name()='Merknad']">
					<div class="eh-col-1 eh-field eh-last-child">
						<div class="eh-label xs">Merknad</div>
						<div class="eh-text"><xsl:value-of select="child::*[local-name()='Merknad']"/></div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>

		<xsl:for-each select="child::*[local-name()='NeedTranslator']"> <!-- v1.0, maxOccurs="unbounded" -->
			<xsl:if test="position()=1">
				<div class="eh-row-8 md">
					<div class="eh-col-1 eh-last-child">
						<hr/>
					</div>
				</div>
				<div class="eh-row-8">
					<div class="eh-col-1 eh-label">Behov for tolk</div>
					<xsl:if test="..//child::*[local-name()='NeedTranslator']/child::*[local-name()='Person']">
						<div class="eh-col-1 md eh-label">Person-referanse</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='NeedTranslator'][child::*[local-name()='IsDeaf']/@V='true'] or ..//child::*[local-name()='NeedTranslator'][child::*[local-name()='IsBlind']/@V='true']">
						<div class="eh-col-1 md eh-label">Handikap</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='NeedTranslator']/child::*[local-name()='Language']">
						<div class="eh-col-1 md eh-label">Språk</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='NeedTranslator']/child::*[local-name()='PreferredTranslator']">
						<div class="eh-col-1 md eh-label">Referanse til foretrukket tolk</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='NeedTranslator']/child::*[local-name()='TranslatorEndDate']">
						<div class="eh-col-1 md eh-label">Behov opphørt dato</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='NeedTranslator']/child::*[local-name()='Note']">
						<div class="eh-col-1 md eh-label eh-last-child">Merknad</div>
					</xsl:if>
				</div>
			</xsl:if>
			<div class="eh-row-8">
				<div class="eh-col-1 md eh-label">&#160;</div>
				<xsl:if test="..//child::*[local-name()='NeedTranslator']/child::*[local-name()='Person']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Person-referanse</div>
						<div class="eh-text"><xsl:value-of select="child::*[local-name()='Person']"/></div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='NeedTranslator'][child::*[local-name()='IsDeaf']/@V='true'] or ..//child::*[local-name()='NeedTranslator'][child::*[local-name()='IsBlind']/@V='true']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Handikap</div>
						<div class="eh-text">
							<xsl:if test="child::*[local-name()='IsDeaf']/@V='true'">Døv</xsl:if>
							<xsl:if test="child::*[local-name()='IsDeaf']/@V='true' and child::*[local-name()='IsBlind']/@V='true'">&#160;og&#160;</xsl:if>
							<xsl:if test="child::*[local-name()='IsBlind']/@V='true'">Blind</xsl:if>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='NeedTranslator']/child::*[local-name()='Language']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Språk</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='Language']">
								<xsl:call-template name="k-3303"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='NeedTranslator']/child::*[local-name()='PreferredTranslator']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Referanse til foretrukket tolk</div>
						<div class="eh-text"><xsl:value-of select="child::*[local-name()='PreferredTranslator']"/></div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='NeedTranslator']/child::*[local-name()='TranslatorEndDate']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Behov opphørt dato</div>
						<div class="eh-text">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='TranslatorEndDate']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='NeedTranslator']/child::*[local-name()='Note']">
					<div class="eh-col-1 eh-field eh-last-child">
						<div class="eh-label xs">Merknad</div>
						<div class="eh-text">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Note']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>

		<xsl:for-each select="child::*[local-name()='CareSituation']"> <!-- v1.0, maxOccurs="1"-->
			<xsl:if test="position()=1">
				<div class="eh-row-8 md">
					<div class="eh-col-1 eh-last-child">
						<hr/>
					</div>
				</div>
				<div class="eh-row-8">
					<div class="eh-col-1 eh-label">Omsorgs&#173;situasjon</div>
					<xsl:if test="child::*[local-name()='CustodyType']">
						<div class="eh-col-1 md eh-label">Foreldreansvar</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='CareSituationType']">
						<div class="eh-col-1 md eh-label">Type omsorgssituasjon</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='NativeLanguage']">
						<div class="eh-col-1 md eh-label">Hjemmespråk</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='Description']">
						<div class="eh-col-3 md eh-label eh-last-child">Beskrivelse</div>
					</xsl:if>
				</div>
			</xsl:if>
			<div class="eh-row-8">
				<div class="eh-col-1 md eh-label">&#160;</div>
				<xsl:if test="child::*[local-name()='CustodyType']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Foreldreansvar</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='CustodyType']">
								<xsl:call-template name="k-9513"/>&#160;
							</xsl:for-each>
							<xsl:if test="child::*[local-name()='CustodyOwner']">
								<xsl:value-of select="child::*[local-name()='CustodyOwner']"/>
							</xsl:if>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='CareSituationType']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Type omsorgssituasjon</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='CareSituationType']">
								<xsl:call-template name="k-3105"/>&#160;
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='NativeLanguage']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Hjemmespråk</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='NativeLanguage']">
								<xsl:call-template name="k-8417"/>&#160;
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Description']">
					<div class="eh-col-3 eh-field eh-last-child">
						<div class="eh-label xs">Beskrivelse</div>
						<div class="eh-text">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Description']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>

		<xsl:for-each select="child::*[local-name()='PatRelperson']"> <!-- maxOccurs="unbounded" -->
			<xsl:if test="position()=1">
				<div class="eh-row-4 md">
					<div class="eh-col-1 eh-last-child" style="width: 100%;">
						<hr/>
					</div>
				</div>
				<div class="eh-row-8">
					<div class="eh-col-1 eh-label">Referert person</div>
					<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='Relation'] or ..//child::*[local-name()='PatRelperson']/child::*[local-name()='Description']">
						<div class="eh-col-1 md eh-label">Relasjon/beskrivelse</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='Name']">
						<div class="eh-col-1 md eh-label">Navn</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='OffId']">
						<div class="eh-col-1 md eh-label">Offentlig id</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='Sex'] or ..//child::*[local-name()='PatRelperson']/child::*[local-name()='EthnicBelonging'] or ..//child::*[local-name()='PatRelperson']/child::*[local-name()='DateOfBirth']">
						<div class="eh-col-1 md eh-label">Personlige opplysninger</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='Occupation'] or ..//child::*[local-name()='PatRelperson']/child::*[local-name()='Role']">
						<div class="eh-col-1 md eh-label">Stilling/annen rolle</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='Consent']">
						<div class="eh-col-1 md eh-label">Samtykke</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='Address']">
						<div class="eh-col-1 md eh-label">Adresse</div>
					</xsl:if>
				</div>
			</xsl:if>
			<div class="eh-row-8">
				<div class="eh-col-1 md el-label">&#160;</div>
				<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='Relation'] or ..//child::*[local-name()='PatRelperson']/child::*[local-name()='Description']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Relasjon/beskrivelse</div>
						<div class="eh-text">
							<xsl:if test="child::*[local-name()='Relation']/child::*[local-name()='Guardien']/@V='true'">
								<b>Foresatt: </b>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="child::*[local-name()='Relation']/child::*[local-name()='RelationCode']/@V='9' and child::*[local-name()='Relation']/child::*[local-name()='Description']">
									<xsl:value-of select="child::*[local-name()='Relation']/child::*[local-name()='Description']"/>
								</xsl:when>
								<xsl:when test="child::*[local-name()='Relation']/child::*[local-name()='RelationCode']/@V">
									<xsl:for-each select="child::*[local-name()='Relation']/child::*[local-name()='RelationCode']">
										<xsl:call-template name="k-8422"/>&#160;</xsl:for-each>
								</xsl:when>
								<xsl:when test="child::*[local-name()='Relation']/child::*[local-name()='Description']">
									<xsl:value-of select="child::*[local-name()='Relation']/child::*[local-name()='Description']"/>
								</xsl:when>
								<xsl:when test="child::*[local-name()='Description']">
									<xsl:value-of select="child::*[local-name()='Description']"/>
								</xsl:when>
								<xsl:otherwise>Pasientrelatert person</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='Name']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Navn</div>
						<div class="eh-text"><xsl:value-of select="child::*[local-name()='Name']"/></div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='OffId']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Offentlig id</div>
						<div class="eh-text">
							<b>
								<xsl:for-each select="child::*[local-name()='TypeOffId']">
									<xsl:call-template name="k-8116"/>
								</xsl:for-each>
							</b>&#160;
							<xsl:value-of select="child::*[local-name()='OffId']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='Sex'] or ..//child::*[local-name()='PatRelperson']/child::*[local-name()='EthnicBelonging'] or ..//child::*[local-name()='PatRelperson']/child::*[local-name()='DateOfBirth']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Personlige opplysninger</div>
						<div class="eh-text">
							<xsl:if test="child::*[local-name()='Sex']">
								<div class="eh-label">Kjønn: </div>
								<xsl:for-each select="child::*[local-name()='Sex']">
									<xsl:call-template name="k-3101"/>
								</xsl:for-each>
								<xsl:if test="child::*[local-name()='EthnicBelonging'] or child::*[local-name()='DateOfBirth']">, </xsl:if>
							</xsl:if>
							<xsl:if test="child::*[local-name()='EthnicBelonging']">
								<xsl:for-each select="child::*[local-name()='EthnicBelonging']">
									<xsl:call-template name="k-8423"/>
								</xsl:for-each>
								<xsl:if test="child::*[local-name()='DateOfBirth']">, </xsl:if>
							</xsl:if>
							<xsl:if test="child::*[local-name()='DateOfBirth']">
								<div class="eh-label">født: </div>
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateOfBirth']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</xsl:if>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='Occupation'] or ..//child::*[local-name()='PatRelperson']/child::*[local-name()='Role']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Stilling/annen rolle</div>
						<div class="eh-text">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='Occupation']/@DN">
									<xsl:value-of select="child::*[local-name()='Occupation']/@DN"/>
								</xsl:when>
								<xsl:otherwise>
									<b>Stillingskode: </b><xsl:value-of select="child::*[local-name()='Occupation']/@V"/>
								</xsl:otherwise>
							</xsl:choose>&#8200;
							<xsl:value-of select="child::*[local-name()='Role']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='Consent']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Samtykke</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='Consent']">
								<xsl:if test="child::*[local-name()='ConsentStatus']">
									<div class="eh-label">Samtykke gitt: </div>
									<xsl:for-each select="child::*[local-name()='ConsentStatus']">
										<xsl:call-template name="k-3109"/>
									</xsl:for-each>&#8200;
								</xsl:if>
								<xsl:if test="child::*[local-name()='ConsentDate']">
									<div class="eh-label">Dato: </div>
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='ConsentDate']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="child::*[local-name()='Merknad']">
									<div>
										<div class="eh-label">Merknad: </div>&#160;
										<xsl:call-template name="line-breaks">
											<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
										</xsl:call-template>
									</div>
								</xsl:if>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatRelperson']/child::*[local-name()='Address']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Adresse</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='Address']">
								<xsl:call-template name="Address" />
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>

		<xsl:for-each select="child::*[local-name()='ContactPerson']">
			<xsl:if test="position()=1">
				<div class="eh-row-8 md">
					<div class="eh-col-1 eh-last-child">
						<hr/>
					</div>
				</div>
				<div class="eh-row-8">
					<div class="eh-col-1 eh-label">Kontaktperson</div>
					<xsl:if test="..//child::*[local-name()='ContactPerson']/child::*[local-name()='Referanseperson']">
						<div class="eh-col-1 md eh-label">Person</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='ContactPerson']/child::*[local-name()='OccupationRole']">
						<div class="eh-col-1 md eh-label">Stilling/rolle</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='ContactPerson']/child::*[local-name()='WorkingPlace']">
						<div class="eh-col-1 md eh-label">Arbeidssted</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='ContactPerson']/child::*[local-name()='Merknad']">
						<div class="eh-col-1 md eh-label eh-last-child">Merknad</div>
					</xsl:if>
				</div>
			</xsl:if>
			<div class="eh-row-8">
				<div class="eh-col-1 md eh-label">&#160;</div>
				<xsl:if test="..//child::*[local-name()='ContactPerson']/child::*[local-name()='Referanseperson']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Person</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='Referanseperson']">
								<div>
									<xsl:value-of select="fk1:FamilyName"/>,&#160;<xsl:value-of select="fk1:GivenName"/>&#160;<xsl:value-of select="fk1:MiddleName"/>
								</div>
								<xsl:for-each select=".//fk1:TeleAddress">
									<xsl:call-template name="eh-TeleAddressHode"/>
								</xsl:for-each>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='ContactPerson']/child::*[local-name()='OccupationRole']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Stilling/rolle</div>
						<div class="eh-text"><xsl:value-of select="child::*[local-name()='OccupationRole']"/></div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='ContactPerson']/child::*[local-name()='WorkingPlace']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Arbeidssted</div>
						<div class="eh-text"><xsl:value-of select="child::*[local-name()='WorkingPlace']"/></div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='ContactPerson']/child::*[local-name()='Merknad']">
					<div class="eh-col-1 eh-field eh-last-child">
						<div class="eh-label xs">Merknad</div>
						<div class="eh-text"><xsl:value-of select="child::*[local-name()='Merknad']"/></div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>

		<xsl:for-each select="child::*[local-name()='PatRelInst']">
			<xsl:if test="position()=1">
				<div class="eh-row-8 md">
					<div class="eh-col-1">
						<hr/>
					</div>
				</div>
				<div class="eh-row-8">
					<div class="eh-col-1 eh-label">Referert virksomhet</div>
					<xsl:if test="..//child::*[local-name()='PatRelInst']/child::*[local-name()='NameInst']">
						<div class="eh-col-1 md eh-label">Navn</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatRelInst']/child::*[local-name()='WorkingTime']">
						<div class="eh-col-1 md eh-label">Arbeidstid</div> <!-- v1.0 -->
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatRelInst']/child::*[local-name()='RoleInst']">
						<div class="eh-col-1 md eh-label">Rolle</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatRelInst']/child::*[local-name()='ContactPerson']">
						<div class="eh-col-1 md eh-label">Kontaktperson</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatRelInst']/child::*[local-name()='Address']">
						<div class="eh-col-1 md eh-label">Adresse</div> <!-- v1.0 -->
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatRelInst']/child::*[local-name()='Merknad']">
						<div class="eh-col-1 md eh-label eh-last-child">Merknad</div>
					</xsl:if>
				</div>
			</xsl:if>
			<div class="eh-row-8">
				<div class="eh-col-1 md eh-label">&#160;</div>
				<xsl:if test="..//child::*[local-name()='PatRelInst']/child::*[local-name()='NameInst']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Navn</div>
						<div class="eh-text"><xsl:value-of select="child::*[local-name()='NameInst']"/></div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatRelInst']/child::*[local-name()='WorkingTime']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Arbeidstid</div>
						<div class="eh-text"><xsl:value-of select="child::*[local-name()='WorkingTime']"/></div> <!-- v1.0 -->
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatRelInst']/child::*[local-name()='RoleInst']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Rolle</div>
						<div class="eh-text"><xsl:value-of select="child::*[local-name()='RoleInst']"/></div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatRelInst']/child::*[local-name()='ContactPerson']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Kontaktperson</div>
						<div class="eh-text"><xsl:value-of select="child::*[local-name()='ContactPerson']"/></div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatRelInst']/child::*[local-name()='Address']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Adresse</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='Address']" > <!-- v1.0 -->
								<xsl:call-template name="Address" />
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatRelInst']/child::*[local-name()='Merknad']">
					<div class="eh-col-1 eh-field eh-last-child">
						<div class="eh-label xs">Merknad</div>
						<div class="eh-text"><xsl:value-of select="child::*[local-name()='Merknad']"/></div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="HealthCareProfessional_v1">
		<div class="eh-row-8">
			<xsl:if test="//child::*[local-name()='PatRelHCP']/child::*[local-name()='Relation']">
				<div class="eh-col-1 md eh-label">Pasientrelasjon</div>
			</xsl:if>
			<xsl:if test="//child::*[local-name()='PatRelHCP']//child::*[local-name()='HCProf'] | //child::*[local-name()='PatRelHCP']//child::*[local-name()='HCPerson'] | //child::*[local-name()='PatRelHCP']//child::*[local-name()='Dept']">
				<div class="eh-col-1 md eh-label">
					<xsl:choose>
						<xsl:when test="//child::*[local-name()='PatRelHCP']//child::*[local-name()='Dept'] and (//child::*[local-name()='PatRelHCP']//child::*[local-name()='HCProf'] or //child::*[local-name()='PatRelHCP']//child::*[local-name()='HCPerson'])">Person/avd.</xsl:when>
						<xsl:when test="not(//child::*[local-name()='PatRelHCP']//child::*[local-name()='Dept'])">Person</xsl:when>
						<xsl:otherwise>Avdeling</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:if>
			<xsl:if test="//child::*[local-name()='PatRelHCP']//child::*[local-name()='HCProf']/child::*[local-name()='Id'] | //child::*[local-name()='PatRelHCP']//child::*[local-name()='HCProf']/child::*[local-name()='AdditionalId'] | //child::*[local-name()='PatRelHCP']//child::*[local-name()='HCPerson']/child::*[local-name()='Id'] | //child::*[local-name()='PatRelHCP']//child::*[local-name()='HCPerson']/child::*[local-name()='AdditionalId'] | //child::*[local-name()='PatRelHCP']//child::*[local-name()='Dept']/child::*[local-name()='Id'] | //child::*[local-name()='PatRelHCP']//child::*[local-name()='Dept']/child::*[local-name()='AdditionalId']">
				<div class="eh-col-1 md eh-label">Id</div>
			</xsl:if>
			<xsl:if test="//child::*[local-name()='PatRelHCP']//child::*[local-name()='Inst']/child::*[local-name()='Name']">
				<div class="eh-col-1 md eh-label">Institusjon</div>
			</xsl:if>
			<xsl:if test="//child::*[local-name()='PatRelHCP']//child::*[local-name()='MedSpeciality']">
				<div class="eh-col-1 md eh-label">Medisinsk spesialitet</div>
			</xsl:if>
			<xsl:if test="//child::*[local-name()='PatRelHCP']//child::*[local-name()='Inst']/child::*[local-name()='Id']">
				<div class="eh-col-1 md eh-label">Institusjon-id</div>
			</xsl:if>
			<xsl:if test="//child::*[local-name()='PatRelHCP']/child::*[local-name()='StartDateTime'] | //child::*[local-name()='PatRelHCP']/child::*[local-name()='EndDateTime']">
				<div class="eh-col-1 md eh-label">Tidsrom</div>
			</xsl:if>
			<xsl:if test="//child::*[local-name()='PatRelHCP']//child::*[local-name()='Address']">
				<div class="eh-col-1 md eh-label eh-last-child">Kontaktinformasjon</div>
			</xsl:if>
		</div>
		<xsl:for-each select="child::*[local-name()='Patient']/child::*[local-name()='PatRelHCP']">
			<xsl:call-template name="PatRelHCP"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="HealthCareProfessional_v2">
		<xsl:for-each select="child::*[local-name()='TilknyttetEnhet']">
			<div class="eh-row-4">
				<div  class="eh-col-1">
					<div class="eh-label">Tilknyttet enhet</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Kontaktenhet']">
							<xsl:call-template name="TilknyttetEnhet"/>
						</xsl:for-each>
					</div>
				</div>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='KontaktpersonHelsepersonell']">
			<div class="eh-row-4">
				<div  class="eh-col-1">
					<div class="eh-label">Tilknyttet helseperson</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Kontaktperson']">
							<xsl:call-template name="HealthcareProfessional"/>
						</xsl:for-each>
					</div>
				</div>
				<xsl:if test="child::*[local-name()='Merknad']">
					<div  class="eh-col-1 eh-last-child">
						<div class="eh-label">Merknad</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='AnsvarForRapport']">
			<div class="eh-row-4">
				<div class="eh-col-1">
					<!-- <div class="eh-label">Ansvarlig for rapport</div> -->
					<div class="eh-label">
						<xsl:for-each select="child::*[local-name()='TypeRelasjon']">
							<xsl:choose>
								<xsl:when test="contains(@S,'8254')"><xsl:call-template name="k-8254"/>&#160;</xsl:when>
								<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='AnsvarligRapport']">
							<xsl:call-template name="HealthcareProfessional"/>
						</xsl:for-each>
					</div>
				</div>
				<xsl:if test="child::*[local-name()='Merknad'] or child::*[local-name()='GodkjentDato']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='GodkjentDato'] and not(child::*[local-name()='Merknad'])">Dato godkjent</xsl:when>
								<xsl:otherwise>Merknad</xsl:otherwise>
							</xsl:choose>
						</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
							</xsl:call-template>
							<xsl:if test="child::*[local-name()='GodkjentDato']">
								<div>
									<xsl:if test="child::*[local-name()='Merknad']"><b>Dato godkjent</b>&#160;</xsl:if>
									<xsl:value-of select="child::*[local-name()='GodkjentDato']"/>
								</div>
							</xsl:if>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="VurderingAvHenvisning">
		<xsl:for-each select="child::*[local-name()='Opplysninger']">
			<div class="eh-row-7">
				<xsl:if test="child::*[local-name()='FrittSykehusvalg']">
					<div class="eh-col-1">
						<div class="eh-label">Fritt sykehusvalg</div>
						<div class="eh-field">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='FrittSykehusvalg']='true'">Benyttes</xsl:when>
								<xsl:otherwise>Benyttes ikke</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='VentetidSluttkode']">
					<div class="eh-col-1">
						<div class="eh-label">Ventetid sluttkode</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='VentetidSluttkode']">
								<xsl:choose>
									<xsl:when test="contains(@S,'8445')"><xsl:call-template name="k-8445"/>&#160;</xsl:when>
									<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Omsorgsniva']">
					<div class="eh-col-1">
						<div class="eh-label">Omsorgsnivå</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Omsorgsniva']">
								<xsl:choose>
									<xsl:when test="contains(@S,'8406')"><xsl:call-template name="k-8406"/>&#160;</xsl:when>
									<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='ForlopsId']">
					<div class="eh-col-1">
						<div class="eh-label">Forløps-id</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='ForlopsId']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='RettTilHelsehjelp']">
					<div class="eh-col-1">
						<div class="eh-label">Rett til helsehjelp</div>
						<div class="eh-field">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='RettTilHelsehjelp']='true'">Ja</xsl:when>
								<xsl:otherwise>Nei</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='UtfallAvVurdering']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Utfall av vurdering</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='UtfallAvVurdering']">
								<xsl:choose>
									<xsl:when test="contains(@S,'8485')"><xsl:call-template name="k-8485"/>&#160;</xsl:when>
									<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
		<xsl:if test="child::*[local-name()='DatoMottakOgVurdering']">
			<div class="eh-row-4">
				<xsl:for-each select="child::*[local-name()='DatoMottakOgVurdering']"> <!-- kodeverk: max 4 varianter -->
					<div class="eh-col-1">
						<div class="eh-label">
							<xsl:for-each select="child::*[local-name()='TypeDato']">
								<xsl:choose>
									<xsl:when test="contains(@S,'9147')"><xsl:call-template name="k-9147"/></xsl:when>
									<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtDate">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='Dato']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:for-each>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="PatRelHCP"> <!-- Message/ServReq/Patient/PatRelHCP  maxOccurs="unbounded" (1.0, 1.1) -->

		<xsl:variable name="raw-rows" select="count(.//child::*[local-name()='HCProf'] | .//child::*[local-name()='HCPerson'] | .//child::*[local-name()='Dept'])"/>
		<xsl:variable name="rows">
			<xsl:choose>
				<xsl:when test="$raw-rows&gt;0">
					<xsl:value-of select="$raw-rows"/>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="cssDocRow" >
			<xsl:if test="count(.//child::*[local-name()='HCProf'] | .//child::*[local-name()='HCPerson'] | .//child::*[local-name()='Dept']) &gt; 1">DocRow</xsl:if>
		</xsl:variable>

		<div class="eh-row-8 {$cssDocRow}">
			<xsl:if test="..//child::*[local-name()='PatRelHCP']/child::*[local-name()='Relation']">
				<div class="eh-col-1 eh-field">
					<div class="xs eh-label">Pasientrelasjon</div>
					<div class="eh-text">
						<xsl:for-each select="child::*[local-name()='Relation']">
							<xsl:choose>
								<xsl:when test="namespace-uri() = 'http://www.kith.no/xmlstds/henvisning/2012-02-15'">
									<xsl:call-template name="k-8254"/> <!-- v1.1 -->
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="k-7319"/> <!-- v1.0 -->
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='PatRelHCP']//child::*[local-name()='HCProf'] | ..//child::*[local-name()='PatRelHCP']//child::*[local-name()='HCPerson'] | ..//child::*[local-name()='PatRelHCP']//child::*[local-name()='Dept']">
				<xsl:choose>
					<xsl:when test=".//child::*[local-name()='HCProf'] | .//child::*[local-name()='HCPerson'] | .//child::*[local-name()='Dept']">
						<xsl:for-each select=".//child::*[local-name()='HCProf'] | .//child::*[local-name()='HCPerson'] | .//child::*[local-name()='Dept']">
							<xsl:if test="position()=1">
								<xsl:call-template name="HCProf_HCPerson_Dept"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<div class="eh-col-1 eh-field">&#160;</div>
						<div class="eh-col-1 eh-field">&#160;</div>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='PatRelHCP']//child::*[local-name()='Inst']/child::*[local-name()='Name']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Institusjon</div>
					<div class="eh-text"><xsl:value-of select=".//child::*[local-name()='Inst']/child::*[local-name()='Name']"/></div>
				</div>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='PatRelHCP']//child::*[local-name()='MedSpeciality']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Medisinsk spesialitet</div>
					<div class="eh-text">
						<xsl:for-each select=".//child::*[local-name()='MedSpeciality']">
							<xsl:call-template name="k-8451"/>&#160;
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='PatRelHCP']//child::*[local-name()='Inst']/child::*[local-name()='Id']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Institusjon-id</div>
					<div class="eh-text">
						<xsl:if test=".//child::*[local-name()='Inst']/child::*[local-name()='TypeId']/@V">
							<b>
								<xsl:value-of select=".//child::*[local-name()='Inst']/child::*[local-name()='TypeId']/@V"/>:
							</b>
						</xsl:if>&#160;
						<xsl:value-of select=".//child::*[local-name()='Inst']/child::*[local-name()='Id']"/>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='PatRelHCP']//child::*[local-name()='StartDateTime'] | ..//child::*[local-name()='PatRelHCP']//child::*[local-name()='EndDateTime']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Tidsrom</div>
					<div class="eh-text">
						<xsl:if test="child::*[local-name()='StartDateTime']">
							<b>Start:</b>&#160;
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:if>&#160;
						<xsl:if test="child::*[local-name()='EndDateTime']">
							<div>
								<b>Slutt:</b>&#160;
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</div>
						</xsl:if>
					</div>
				</div>
			</xsl:if>
			<xsl:if test=".//child::*[local-name()='Address']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Kontaktinformasjon</div>
					<div class="eh-text">
						<xsl:for-each select=".//child::*[local-name()='Address']">
							<xsl:call-template name="eh-Address"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
		</div>

		<xsl:for-each select=".//child::*[local-name()='HCProf'] | .//child::*[local-name()='HCPerson'] | .//child::*[local-name()='Dept']">
			<xsl:if test="position()!=1">
				<div class="eh-row-8" style="margin-top: 0;">
					<div class="eh-col-1 eh-label DocRow">&#160;</div>
					<xsl:call-template name="HCProf_HCPerson_Dept" />
					<div class="eh-col-1 eh-field DocRow">&#160;</div>
					<div class="eh-col-1 eh-field DocRow">&#160;</div>
				</div>
			</xsl:if>
		</xsl:for-each>

	</xsl:template>

	<xsl:template name="HCProf_HCPerson_Dept"> <!-- "h:HCProf | h:HCPerson | h:Dept" -->
		<div class="eh-col-1 eh-field">
			<div class="eh-label xs">
				<xsl:choose>
					<xsl:when test="//child::*[local-name()='PatRelHCP']//child::*[local-name()='Dept'] and (//child::*[local-name()='PatRelHCP']//child::*[local-name()='HCProf'] or //child::*[local-name()='PatRelHCP']//child::*[local-name()='HCPerson'])">Person/avd.</xsl:when>
					<xsl:when test="not(//child::*[local-name()='PatRelHCP']//child::*[local-name()='Dept'])">Person</xsl:when>
					<xsl:otherwise>Avdeling</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="eh-text">
				<xsl:if test="child::*[local-name()='Type']/@DN">
					<b>
						<xsl:value-of select="child::*[local-name()='Type']/@DN"/>&#8200;
					</b>
				</xsl:if>
				<xsl:value-of select="child::*[local-name()='Name']"/>
			</div>
		</div>
		<div class="eh-col-1 eh-field">
			<div class="eh-label xs">Id</div>
			<div class="eh-text">
				<xsl:if test="child::*[local-name()='TypeId']/@V">
					<b>
						<xsl:value-of select="child::*[local-name()='TypeId']/@V"/>:
					</b>
				</xsl:if>
				<xsl:value-of select="child::*[local-name()='Id']"/>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="Address" >
		<xsl:choose>
			<xsl:when test="child::*[local-name()='Type']">
				<b>
					<xsl:for-each select="child::*[local-name()='Type']">
						<xsl:call-template name="k-3401"/>:&#160;
					</xsl:for-each>
				</b>
			</xsl:when>
			<xsl:otherwise>
				<b>Adresse:&#160;</b>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="child::*[local-name()='StreetAdr']">
			<xsl:value-of select="child::*[local-name()='StreetAdr']"/>
		</xsl:if>
		<xsl:if test="child::*[local-name()='PostalCode'] or child::*[local-name()='City']">
			<xsl:if test="child::*[local-name()='StreetAdr']">, </xsl:if>
			<xsl:value-of select="child::*[local-name()='PostalCode']"/>&#8200;<xsl:value-of select="child::*[local-name()='City']"/>
		</xsl:if>
		<xsl:if test="child::*[local-name()='CityDistr']">, <xsl:for-each select="child::*[local-name()='CityDistr']">
				<xsl:call-template name="k-3403"/>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="child::*[local-name()='County']">, <xsl:for-each select="child::*[local-name()='County']">
				<xsl:call-template name="k-3402"/>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Country']">, <xsl:for-each select="child::*[local-name()='Country']">
				<xsl:call-template name="k-9043"/>
			</xsl:for-each>
		</xsl:if>
		&#160;
		<xsl:for-each select="child::*[local-name()='TeleAddress']">
			<xsl:call-template name="eh-TeleAddressHode"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av vedlegg -->
	<!-- Deprecated: se felleskomponenter/eh-komponent1.xsl : eh-RefDoc -->
	<xsl:template name="RefDoc"> <!-- v1.0 og v1.1 only. (v1.0 har ikke selve vedlegget). v2.0 : se meldinshode2html.xsl. -->
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='MsgType'] or child::*[local-name()='Id'] or child::*[local-name()='IssueDate'] or child::*[local-name()='MimeType'] or child::*[local-name()='Compression']">
			<div class="eh-row-5">
				<xsl:if test="child::*[local-name()='MsgType']">
					<div class="eh-col-1">
						<div class="eh-label">Type</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='MsgType']">
								<xsl:choose>
									<xsl:when test="namespace-uri() = 'http://www.kith.no/xmlstds/henvisning/2012-02-15'">
										<xsl:call-template name="k-8114"/> <!-- v1.1 -->
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="k-8263"/> <!-- v1.0 -->
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Id']">
					<div class="eh-col-1">
						<div class="eh-label">Id</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='IssueDate']">
					<div class="eh-col-1">
						<div class="eh-label">Utstedt-dato</div>
						<div class="eh-field blk">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>

				<xsl:if test="child::*[local-name()='MimeType']">
					<div class="eh-col-1">
						<div class="eh-label">Mimetype</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='MimeType']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Compression']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Komprimering</div>
						<div class="eh-field blk">
							<xsl:for-each select="child::*[local-name()='Compression']">
								<xsl:call-template name="k-1204"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
			<xsl:if test="child::*[local-name()='Booking']"> <!-- v1.0 only -->
				<div class="eh-row-4">
					<div class="eh-col-1">
						<div class="eh-label">Booking</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Booking']">
								<xsl:value-of select="child::*[local-name()='Name']"/>&#8200;
								<b>
									<xsl:choose>
										<xsl:when test="child::*[local-name()='TypeId']/@V">
											<xsl:value-of select="child::*[local-name()='TypeId']/@V"/>:</xsl:when>
										<xsl:otherwise>Id:</xsl:otherwise>
									</xsl:choose>
								</b>&#8200;
								<xsl:value-of select="child::*[local-name()='Id']"/>
								<xsl:for-each select=".//child::*[local-name()='SubOrg']">
									<xsl:call-template name="eh-SubOrg" />
								</xsl:for-each>
							</xsl:for-each>
						</div>
					</div>
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Avtale</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Booking']/child::*[local-name()='Appointment']">
								<div>
									<b>Tidspunkt: </b>
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
									<b> til </b>
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</div>
								<div>
									<b> Ressurs: </b>
									<xsl:value-of select="child::*[local-name()='ResourceId']"/>
									<b> Index: </b>
									<xsl:value-of select="child::*[local-name()='Index']"/>
								</div>
								<div>
									<b> Service: </b>
									<xsl:for-each select="child::*[local-name()='Service']">
										<xsl:call-template name="k-8264"/>
									</xsl:for-each>
								</div>
							</xsl:for-each>
						</div>
					</div>
				</div>
			</xsl:if>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Description']">
			<div class="eh-row-4 blk-cmt">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Beskrivelse</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Description']"/>
						</xsl:call-template>
					</div>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Content'] or child::*[local-name()='FileReference']"> <!-- v1.1 only -->
			<xsl:choose>
				<xsl:when test="contains(child::*[local-name()='MimeType'],'image')">
					<div class="eh-row-8">
						<div class="eh-col-1 eh-label">Bilde</div>
						<div class="eh-col-1 eh-field eh-last-child">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='FileReference']">
									<img style="max-width: 100%;">
										<xsl:attribute name="src"><xsl:value-of select="child::*[local-name()='FileReference']"/></xsl:attribute>
										<xsl:attribute name="alt">Bilde fra ekstern URL</xsl:attribute>
									</img>
								</xsl:when>
								<xsl:when test="child::*[local-name()='Content']">
									<xsl:choose>
										<xsl:when test="child::*[local-name()='Content']/base:Base64Container">
											<img style="max-width: 100%;">
												<xsl:attribute name="src"><xsl:value-of select="concat('data:',child::*[local-name()='MimeType'],';base64,',child::*[local-name()='Content']/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="alt">Bilde vedlagt som base64-kode</xsl:attribute>
											</img>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="child::*[local-name()='Content']"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>
						</div>
					</div>
				</xsl:when>
				<xsl:when test="contains(child::*[local-name()='MimeType'],'pdf') or contains(child::*[local-name()='MimeType'],'PDF')">
					<div class="eh-row-4 bl-cmt">
						<div class="eh-col-1 eh-last-child">
							<div class="eh-label">pdf</div>
							<div class="eh-field">Hvis du ikke ser pdf-vedlegget kan du prøve en annen nettleser.</div>
						</div>
					</div>
					<div class="eh-row-8 NoPrint">
						<div class="eh-col-1">
							<div class="eh-col-1 md eh-field">&#160;</div>
							<div class="eh-col-1 eh-field">
								<xsl:choose>
									<xsl:when test="child::*[local-name()='FileReference']">
										<object>
											<xsl:attribute name="data">
												<xsl:value-of select="concat(child::*[local-name()='FileReference'],'&#35;view&#61;FitH&#38;toolbar&#61;1')"/>
											</xsl:attribute>
											<xsl:attribute name="type">application/pdf</xsl:attribute>
											<xsl:attribute name="width">100%</xsl:attribute>
											<xsl:attribute name="height">500px</xsl:attribute>
										</object>
									</xsl:when>
									<xsl:when test="child::*[local-name()='Content']">
										<xsl:choose>
											<xsl:when test="child::*[local-name()='Content']/base:Base64Container">
												<object>
													<xsl:attribute name="data">
														<xsl:value-of select="concat('data:application/pdf;base64,',child::*[local-name()='Content']/base:Base64Container)"/>
													</xsl:attribute>
													<xsl:attribute name="type">application/pdf</xsl:attribute>
													<xsl:attribute name="width">100%</xsl:attribute>
													<xsl:attribute name="height">500px</xsl:attribute>
												</object>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="child::*[local-name()='Content']"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
								</xsl:choose>
							</div>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="eh-row-4">
						<div class="eh-col-1 eh-last-field">
							<div class="eh-field">
								<xsl:choose>
									<xsl:when test="child::*[local-name()='Content']">
										<xsl:value-of select="child::*[local-name()='Content']"/>
									</xsl:when>
									<xsl:when test="child::*[local-name()='FileReference']">
										<xsl:value-of select="child::*[local-name()='FileReference']"/>
									</xsl:when>
								</xsl:choose>
							</div>
						</div>
					</div>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template name="ServReq_Henvisning"> <!-- Message/ServReq (1.0, 1.1) eller /MsgHead/Document/Content/Henvisning (v2.0)-->
		<div  class="eh-row-4">
			<xsl:for-each select="child::*[local-name()='TypeInnholdIMelding']/child::*[local-name()='TypeInnhold']">
				<div class="eh-col-1">
					<div class="eh-label">Type henvisning</div>
					<div class="eh-field">
						<xsl:choose>
							<xsl:when test="contains(@S,'8455')"><xsl:call-template name="k-8455"/></xsl:when>
							<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:for-each>
			<xsl:if test="child::*[local-name()='IssueDate']">
				<div class="eh-col-1">
					<div class="eh-label">Utstedt</div>
					<div class="eh-field">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='IssueDate']/@V"> <!-- kith:TS -->
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise> <!-- dateTime, date etc. -->
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="child::*[local-name()='PaymentCat'] and not(namespace-uri() = 'http://www.kith.no/xmlstds/henvisning/2005-07-08')" >
					<div class="eh-col-1">
					<div class="eh-label">Betalings&#173;kategori</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='PaymentCat']">
							<xsl:call-template name="k-4101"/>
						</xsl:for-each>
					</div>
				</div>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="child::*[local-name()='PaymentCat']">
						<div class="eh-col-1">
							<div class="eh-label">Betalings&#173;kategori</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='PaymentCat']">
									<xsl:call-template name="k-4101"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
			    </xsl:otherwise>
			</xsl:choose>

			<xsl:if test="child::*[local-name()='Ack']"> <!-- (1.0, 1.1) -->
				<div class="eh-col-1">
					<div class="eh-label">Meldings&#173;bekreftelse</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Ack']">
							<xsl:call-template name="k-7304"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="//child::*[local-name()='MsgInfo']/child::*[local-name()='Ack']"> <!-- (2.0) -->
				<div class="eh-col-1">
					<div class="eh-label">Meldings&#173;bekreftelse</div>
					<div class="eh-field">
						<xsl:for-each select="//child::*[local-name()='MsgInfo']/child::*[local-name()='Ack']">
							<xsl:call-template name="k-7304"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>

			<xsl:if test="child::*[local-name()='TypeInnholdIMelding']/child::*[local-name()='Merknad']">
				<div class="eh-col-1">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='TypeInnholdIMelding']/child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>

		</div>

		<xsl:for-each select="child::*[local-name()='ReqServ']">
			<xsl:call-template name="ServReq_ReqServ"/>
		</xsl:for-each>

	   <!-- Legger inn sjekk om noen dokumenter er sendt som kan være relevante (v2.0) SendtDokument-->
		<xsl:if test="child::*[local-name()='SendtDokument']">
			<div class="eh-col-1">
				<div class="eh-label">Sendte dokumenter</div>
				<div class="eh-field">
					<div  class="eh-row-5">
					<xsl:for-each select="child::*[local-name()='SendtDokument']">
						<xsl:if test="//child::*[local-name()='SendtDokument']/child::*[local-name()='Opplysning']">
							<div class="eh-col-1">
								<div class="eh-label">Dokument&#173;type</div>
								<div class="eh-field">
									<xsl:for-each select="child::*[local-name()='Opplysning']">
										<xsl:call-template name="k-8329"/>
									</xsl:for-each>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="//child::*[local-name()='SendtDokument']/child::*[local-name()='JaNei']">
							<div class="eh-col-1">
								<div class="eh-label">Sendt</div>
								<div class="eh-field">
									<xsl:if test="//child::*[local-name()='SendtDokument']/child::*[local-name()='JaNei']='false'">
										Nei
									</xsl:if>
									<xsl:if test="//child::*[local-name()='SendtDokument']/child::*[local-name()='JaNei']='true'">
										Ja
									</xsl:if>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="//child::*[local-name()='JaNei'] and //child::*[local-name()='DatoSendt']">
							<div class="eh-col-1">
								<div class="eh-label">Dato sendt</div>
								<div class="eh-field">
									<xsl:call-template name="skrivUtDate">
										<xsl:with-param name="oppgittTid" select="//child::*[local-name()='DatoSendt']"/>
									</xsl:call-template>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="//child::*[local-name()='TypeMottaker']/@V and //child::*[local-name()='NavnMottaker']">
							<div class="eh-col-1">
								<div class="eh-label">Mottaker</div>
								<div class="eh-field">
									<xsl:for-each select="//child::*[local-name()='TypeMottaker']">
										<xsl:call-template name="k-8330"/>
									</xsl:for-each>,&#160;
									<xsl:value-of select="//child::*[local-name()='NavnMottaker']"/>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="not(//child::*[local-name()='TypeMottaker']) and //child::*[local-name()='NavnMottaker']">
							<div class="eh-col-1">
								<div class="eh-label">Mottaker</div>
								<div class="eh-field">
									<xsl:value-of select="//child::*[local-name()='NavnMottaker']"/>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="//child::*[local-name()='TypeMottaker']/@V and not(//child::*[local-name()='NavnMottaker'])">
							<div class="eh-col-1">
								<div class="eh-label">Mottaker</div>
								<div class="eh-field">
									<xsl:for-each select="//child::*[local-name()='TypeMottaker']">
										<xsl:call-template name="k-8330"/>
									</xsl:for-each>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="//child::*[local-name()='SendtDokument']/child::*[local-name()='Merknad']">
							<div class="eh-col-1">
								<div class="eh-label">Merknad</div>
								<div class="eh-field">
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
									</xsl:call-template>
								</div>
							</div>
						</xsl:if>
					</xsl:for-each>
					</div>
				</div>
			</div>
		</xsl:if>
		<!-- SendDokumenter slutt -->
	</xsl:template>

	<xsl:template name="ServReq_ReqServ"> <!-- Message/ServReq/ReqServ (1.0, 1.1) eller .../Content/Henvisning/ReqServ (v2.0) -->
		<div class="eh-row-4">
			<xsl:if test="child::*[local-name()='Priority']">
				<div class="eh-col-1">
					<div class="eh-label">Hastegrad</div>
					<div class="eh-field">
						<xsl:choose>
							<xsl:when test="namespace-uri() = 'http://ehelse.no/xmlstds/henvisning/2017-11-30'"><!-- Henvisning v2.0-->
								<xsl:for-each select="child::*[local-name()='Priority']">
									<xsl:call-template name="k-8306"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise><!-- Henvisning v1.0 og v1.1 -->
								<xsl:for-each select="child::*[local-name()='Priority']">
								<xsl:call-template name="k-8304"/>
							</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Purpose']">
				<div class="eh-col-1">
					<div class="eh-label">Formål</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Purpose']">
							<xsl:call-template name="k-8248"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='ReqDate']">
				<div class="eh-col-1">
					<div class="eh-label">Utstedt</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='ReqDate']">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
		</div>

		<xsl:for-each select="child::*[local-name()='Service']">
			<xsl:call-template name="ReqServ_Service"/>
		</xsl:for-each>

		<xsl:if test="child::*[local-name()='Comment']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-last-child">
				<div class="eh-label">Kommentar</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Comment']"/>
						</xsl:call-template>
					</div>
				</div>
			</div>
		</xsl:if>

	</xsl:template>

	<xsl:template name="ReqServ_Service"> <!-- Message/ServReq/ReqServ/Service (1.0, 1.1) eller .../Content/Henvisning/ReqServ/Service (v2.0)-->
		<div  class="eh-row-4">
			<xsl:if test="child::*[local-name()='ServId']">
				<div class="eh-col-1">
					<div class="eh-label">Spesifisert tjeneste</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='ServId']">
							<xsl:choose>
								<xsl:when test="@DN or @OT">
									<xsl:call-template name="k-dummy"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@V"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='MedSpeciality']">
				<div class="eh-col-1">
					<div class="eh-label">Medisinsk spesialitet</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='MedSpeciality']">
							<xsl:choose>
								<xsl:when test="contains(@S,'7426')">
									<xsl:call-template name="k-7426"/>
								</xsl:when>
								<xsl:when test="contains(@S,'8451')">
									<xsl:call-template name="k-8451"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="k-dummy"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='AdmCat']">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Type tjeneste</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='AdmCat']">
							<xsl:call-template name="k-8240"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Deprecated: se felleskomponenter/eh-komponent1.xsl : eh-SubOrg -->
	<xsl:template name="SubOrg"> <!-- v1.0 only -->
		<div>
			<xsl:value-of select="child::*[local-name()='Name']"/>&#8200;
			<b>
				<xsl:choose>
					<xsl:when test="child::*[local-name()='TypeId']">
						<xsl:value-of select="child::*[local-name()='TypeId']"/>:</xsl:when>
					<xsl:otherwise>Id:</xsl:otherwise>
				</xsl:choose>
			</b>&#8200;
			<xsl:value-of select="child::*[local-name()='Id']"/>
		</div>
	</xsl:template>

	<xsl:template name="Diagnosis-DiagComment-CodedDescr-CodedComment">
	</xsl:template>
</xsl:stylesheet>
