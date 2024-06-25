<?xml version="1.0" encoding="utf-8"?>
<!--
Endringslogg:
- 01.02.24: v5.4.1 - Fiks for visning av innhold med xhtml-feil
- 09.08.22: v5.4.0 - Semantisk Html
- 01.07.22: v5.3.1 - Lagt til pasientens adresse og telefonnummer
- 30.05.22: v5.3.0 - Oppdatert Footer (Dokumentinformasjon)
- 16.05.22: v5.2.1 - Legg til fødselsdag og kjønn i Header hvis fødselsnummer ikke finnes + kopimottakere i Header på egen linje
- 03.09.21: v5.2.0 - Fjern 'Ny' og 'Endelig rapport'.
					 Flytt Informasjon til pasient/pårørende til sammendraget.
					 Unngå tomme felter under Tilbakemelding (uspes.).
					 Legg til flere felter og endre oppsett i Header.
					 Endre størrelse felter under Legemiddelopplysninger.
					 Kodeverk 8244 i rød tekst.
- 04.06.21: v5.1.3 - Lagt til xsl:output for å definere at output formatet skal være html
- 31.05.21: v5.1.2 - Tillate MimeType (vedlegg) med store bokstaver
- 12.05.21: v5.1.1 - Fjern tomme <div>'s
- 13.04.21: v5.1.0 - Legg til PROB og UTRED
- 27.04.21: v5.0.1 - Oppdater regler for visning av Pasient-informasjon
- 08.04.21: v5.0.0 - Endre <span> til <div>, siden block-elementer (<ul>) inni inline-elementer (<span>) kan gi feil visning.
- 25.03.21: v4.2.0 - Legg til Andre relevante tilstander (ART)
- 19.06.18: v4.1.4 - Fjernet unødvendige overskrifter i legemiddelvisning
- 18.05.17: v4.1.3 - Endret fra Rekvirent til Mottaker og Tjenesteyter til Avsender under "Helsetjenesteenheter"
					Endret logikk i visning av  Type opprinnelig visning. Tar nå tekst som er med i dis:MsgDescr, istedet for @V som ikke er med uansett siden det ikke er tillatt
					Fjernet visning av henvisningsdiagnose i epikrise-diagnosevisning. Flyttet den til feltet "Opprinnelig henvisning"
- 09.05.17: v4.1.2 - Rettet formell feil : fjernet parameter på templatekall "eh-TeleAddress"
- 17.03.17: v4.1.1 - Ny stil "Smooth".
- 20.01.17: v4.1.0 - Html/Css responsive. Rettet feil vedr. kolonne-forskyvning under Hendelser.
- 10.11.16: v4.0.0 - Ny versjonsuavhengig visning
- 01.11.16: Justeringer av layout etter innspill fra brukere. Bl.a.: Vurdering og Videre oppfølging plassert langt oppe og med grå bakgrunn.
- 12.05.16: Komplettering av Helsetjenesteenheter-tabellen
- 05.11.15: Innføring av felles kodeverksfil
- 01.04.12: Første versjon

Design:
- Responsive kollaps ved 767px bredde.
- Ingen tomme felt så langt det lar seg gjøre
- Klikkbar menylinje
- Headervisning avhengig av utskriftsmedium
- Kommentarer for ofte tildelt fulle rader
Om:
- Inngår i Direktoratet for e-helse visningsfiler

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:base="http://www.kith.no/xmlstds/base64container"
	xmlns:doc12="http://www.kith.no/xmlstds/epikrise/2012-02-15"
	exclude-result-prefixes="xhtml base">

	<!-- Import. Stien tilrettelegger for katalogstruktur med en meldings-katalog med versjons-kataloger inni. Sti må endres om slik struktur ikke benyttes -->
	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../felleskomponenter/eh-komponent1.xsl"/>
	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'epikrise v.uavhengig - v5.4.1'"/>

	<!-- Variabeler for standard antall kolonner i tabellene -->
	<xsl:variable name="std-col" select="8"/>

	<!-- Boolske variabler for visning av 'Vis/Skjul' knapp ved hver overskrift. Settes til 'true()' om knappen skal vises -->
	<xsl:variable name="VisDiagnoserVisSkjul" select="false()"/>
	<xsl:variable name="VisVurderingVisSkjul" select="false()"/>
	<xsl:variable name="VisVidereOppfolgingVisSkjul" select="false()"/>
	<xsl:variable name="VisUtredningVisSkjul" select="false()"/>
	<xsl:variable name="VisCAVEVisSkjul" select="false()"/>
	<xsl:variable name="VisAarsakInnleggelseVisSkjul" select="false()"/>
	<xsl:variable name="VisAarsakHenvisningVisSkjul" select="false()"/>
	<xsl:variable name="VisKliniskeOpplysningerVisSkjul" select="false()"/>
	<xsl:variable name="VisSykehistorieVisSkjul" select="false()"/>
	<xsl:variable name="VisResultatVisSkjul" select="false()"/>
	<xsl:variable name="VisForlopBehandlingVisSkjul" select="false()"/>
	<xsl:variable name="VisMedisineringVisSkjul" select="false()"/>
	<xsl:variable name="VisFunksjonVisSkjul" select="false()"/>
	<xsl:variable name="VisSykmeldingVisSkjul" select="false()"/>
	<xsl:variable name="VisProsedyrerVisSkjul" select="false()"/>
	<xsl:variable name="VisAndreKliniskeVisSkjul" select="false()"/>
	<xsl:variable name="VisFamilieVisSkjul" select="false()"/>
	<xsl:variable name="VisInfoPasientVisSkjul" select="false()"/>
	<xsl:variable name="VisUbesvarteVisSkjul" select="false()"/>
	<xsl:variable name="VisTilbakemeldingVisSkjul" select="false()"/>
	<xsl:variable name="VisOvrigPasientInfoVisSkjul" select="true()"/>
	<xsl:variable name="VisOvrigHelsetjenesteInfoVisSkjul" select="true()"/>
	<xsl:variable name="VisHendelseVisSkjul" select="true()"/>
	<xsl:variable name="VisRefDokVisSkjul" select="true()"/>
	<xsl:variable name="VisOpprinneligHenvisningVisSkjul" select="true()"/>
	<xsl:variable name="VisDokInfoVisSkjul" select="true()"/>

	<!-- Boolsk variabel om menylinjen skal vises. Settes til true() om den skal vises. -->
	<xsl:variable name="VisMenylinje" select="false()"/>

	<!-- Boolsk variabel for å anonymisere pasienten i visningen -->
	<xsl:variable name="Anonymisert" select="false()"/>

	<xsl:variable name="IsTestMessage" select="boolean(/doc12:Message/doc12:Status[@V = 'TEST']) or contains(/comment(), 'test') or contains(/comment(), 'TEST')" />

	<xsl:template match="/">
		<html>
			<head>
				<title>Epikrise</title>
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
			<body class="{$stil}">
				<xsl:if test="$IsTestMessage">
					<p class="TestMessageWarning">OBS: Dette er en testmelding.</p>
				</xsl:if>
				<xsl:for-each select="child::*[local-name()='Message']">
					<xsl:call-template name="Message"/>
				</xsl:for-each>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="Message">
		<xsl:for-each select="child::*[local-name()='ServRprt']">
			<!-- utelater meldingsid og kommunikasjonsinformasjon -->
			<xsl:call-template name="Header"/>
			<xsl:call-template name="ResultBody"/>
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
						<xsl:if test="child::*[local-name()='Patient']/child::*[local-name()='DateOfDeath']">
							<div class="No-line-headerContent">
								<div class="No-line-caption">Dødsdato&#160;</div>
								<div class="No-line-content">
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='Patient']/child::*[local-name()='DateOfDeath']/@V"/>
									</xsl:call-template>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='Patient']/child::*[local-name()='Address']">
							<div class="No-line-headerContent">
								<div class="No-line-caption">Telefon&#160;</div>
								<div class="No-line-content">
									<xsl:value-of select="substring-after(child::*[local-name()='Patient']/child::*[local-name()='Address']/child::*[local-name()='TeleAddress']/@V, ':')"/>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='Patient']/child::*[local-name()='ResultItem']/child::*[local-name()='InvDate']">
							<div class="No-line-headerContent">
								<div class="No-line-caption">Dato&#160;undersøkelse&#160;</div>
								<div class="No-line-content">
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='Patient']/child::*[local-name()='ResultItem']/child::*[local-name()='InvDate'][1]/@V"/>
									</xsl:call-template>
								</div>
							</div>
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
						<xsl:for-each select="child::*[local-name()='ServProvider']">
							<xsl:call-template name="ServProviderHode"/>
						</xsl:for-each>
					</div>
				</div>
				<xsl:if test="descendant::*[local-name()='PatRelHCP']/child::*[local-name()='Relation'][@V='HHE']">
					<div class="No-line-headerContent">
						<div class="No-line-caption">Henviser&#160;</div>
						<div class="No-line-content">
							<xsl:value-of select="descendant::*[local-name()='PatRelHCP']//child::*[local-name()='Name']"/>
						</div>
					</div>
				</xsl:if>
				<div class="No-line-headerContent">
					<div class="No-line-caption">Mottaker&#160;</div>
					<div class="No-line-content">
						<xsl:for-each select="child::*[local-name()='Requester']">
							<xsl:call-template name="RequesterHode"/>
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
			<xsl:choose>
				<xsl:when test="ancestor::*[local-name()='ServProvider']">
					<b style="font-size:1.3em;"><xsl:value-of select="child::*[local-name()='Name']"/></b>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="child::*[local-name()='Name']"/></xsl:otherwise>
			</xsl:choose>
			<!--<xsl:value-of select="child::*[local-name()='Name']"/>-->
			<div class="NoPrint">,</div>&#160;
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
			<xsl:choose>
				<xsl:when test="ancestor::*[local-name()='ServProvider']">
					<b style="font-size:1.5em;"><xsl:value-of select="child::*[local-name()='Name']"/></b>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="child::*[local-name()='Name']"/></xsl:otherwise>
			</xsl:choose>
			<!--<xsl:value-of select="child::*[local-name()='Name']"/>-->
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
				<xsl:call-template name="k-9060"/>
			</xsl:for-each>&#160;
			<xsl:choose>
				<xsl:when test="ancestor::*[local-name()='ServProvider']">
					<b style="font-size:1.3em;"><xsl:value-of select="child::*[local-name()='Name']"/></b>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="child::*[local-name()='Name']"/></xsl:otherwise>
			</xsl:choose>
			<!--<xsl:value-of select="child::*[local-name()='Name']"/>-->
		</div>
	</xsl:template>


	<xsl:template name="CopyDestHode">
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCPHode"/>
		</xsl:for-each>
	</xsl:template>


	<!-- Hoveddokumentet -->
	<xsl:template name="ResultBody"> <!-- Message/ServRprt -->
		<xsl:variable name="position" select="position()"/>
		<xsl:variable name="color">
			<xsl:choose>
				<xsl:when test="child::*[local-name()='ServType'][@V='M' or @V='C' or @V='O']">red</xsl:when>
				<xsl:otherwise>black</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<main class="{$stil}">
			<xsl:if test="$VisMenylinje">
				<xsl:call-template name="FellesMeny">
					<xsl:with-param name="position" select="position()"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Overskrift og tabell for epikrisen -->
			<h1>
				<xsl:choose>
					<xsl:when test="child::*[local-name()='MsgDescr'] and string-length(child::*[local-name()='MsgDescr']) &gt; 0">
						<xsl:value-of select="child::*[local-name()='MsgDescr']"/>
					</xsl:when>
					<xsl:otherwise>Epikrise</xsl:otherwise>
				</xsl:choose>
				<xsl:for-each select="child::*[local-name()='ServType'][@V!='N']">&#160;-
					<span style="color:{$color};"><xsl:call-template name="k-7309"/></span>
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='Status'][@V!='F']">&#160;-&#160;<xsl:call-template name="k-7306"/>
				</xsl:for-each>
			</h1>

			<section class="eh-section">
				<xsl:call-template name="ServRprt"/>
			</section>

			<section class="summary">

				<!-- Overskrift og tabell for Diagnoser -->
				<xsl:if test="//child::*[local-name()='Diagnosis'] or //child::*[local-name()='DiagComment'] or //child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='DIAG'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='H' or child::*[local-name()='Type']/@V='B']">
					<xsl:variable name="id1">
						<xsl:value-of select="concat('Diagnosis',$position)"/>
					</xsl:variable>

					<h2 id="{$id1}">Diagnoser</h2>

					<xsl:if test="$VisDiagnoserVisSkjul">
						<label for="vis{$id1}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id1}" style="display: none; margin-bottom:0em;"/>
					</xsl:if>

					<div class="eh-section" style="padding-left:1em; margin-left:0em;">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='H']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='B']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='DiagComment']">
							<div class="eh-row-4">
								<xsl:call-template name="Diagnosis-DiagComment-CodedDescr-CodedComment"/>
							</div>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='DIAG']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
					</div>
				</xsl:if>

				<!-- Overskrift og tabell for Vurdering -->
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='VU']">
					<xsl:variable name="id6">
						<xsl:value-of select="concat('VU',$position)"/>
					</xsl:variable>

					<h2 id="{$id6}">Vurdering</h2>

					<xsl:if test="$VisVurderingVisSkjul">
						<label for="vis{$id6}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id6}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section" style="padding-left:1em; margin-left:0em;">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='VU']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
					</div>
				</xsl:if>

				<!-- Overskrift og tabell for Videre oppfølging -->
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='OP']">
					<xsl:variable name="id11">
						<xsl:value-of select="concat('OP',$position)"/>
					</xsl:variable>

					<h2 id="{$id11}">Videre&#160;oppfølging</h2>

					<xsl:if test="$VisVidereOppfolgingVisSkjul">
						<label for="vis{$id11}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id11}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section" style="padding-left:1em; margin-left:0em;">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='OP']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
					</div>
				</xsl:if>

				<!-- Overskrift og tabell for Forventet utredning/behandling -->
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='UTRED']">
					<xsl:variable name="id17">
						<xsl:value-of select="concat('UTRED',$position)"/>
					</xsl:variable>

					<h2 id="{$id17}">Forventet&#160;utredning/behandling</h2>

					<xsl:if test="$VisUtredningVisSkjul">
						<label for="vis{$id17}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id17}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section" style="padding-left:1em; margin-left:0em;">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='UTRED']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
					</div>
				</xsl:if>

				<!-- Overskrift og tabell for Informasjon til pasient/pårørende -->
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='IP']">
					<xsl:variable name="id14">
						<xsl:value-of select="concat('IP',$position)"/>
					</xsl:variable>

					<h2 id="{$id14}">Informasjon&#160;til&#160;pasient/pårørende</h2>

					<xsl:if test="$VisInfoPasientVisSkjul">
						<label for="vis{$id14}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id14}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section" style="padding-left:1em; margin-left:0em;">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='IP']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
					</div>
				</xsl:if>
			</section>

			<!-- Overskrift og tabell for CAVE og NB-opplysninger -->
			<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='CAVE' or child::*[local-name()='Type']/@V='NB']">
				<xsl:variable name="id2">
					<xsl:value-of select="concat('CAVE',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id2}">Kritisk informasjon</h2>

					<xsl:if test="VisCAVEVisSkjul">
						<label for="vis{$id2}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id2}" style="display: none; margin-bottom:0em;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='CAVE']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='NB']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Årsak til innleggelse -->
			<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='AI'] or //child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='ÅI']">
				<xsl:variable name="id3">
					<xsl:value-of select="concat('AI',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id3}">Årsak&#160;til&#160;innleggelse</h2>

					<xsl:if test="VisAarsakInnleggelseVisSkjul">
						<label for="vis{$id3}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id3}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='AI']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='ÅI']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Årsak til henvisning -->
			<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='AH']">
				<xsl:variable name="id4">
					<xsl:value-of select="concat('AH',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id4}">Årsak&#160;til&#160;henvisning</h2>

					<xsl:if test="$VisAarsakHenvisningVisSkjul">
						<label for="vis{$id4}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id4}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='AH']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Kliniske opplysninger -->
			<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='OPPL']">
				<xsl:variable name="id50">
					<xsl:value-of select="concat('OPPL',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id50}">Kliniske&#160;opplysninger</h2>

					<xsl:if test="VisKliniskeOpplysningerVisSkjul">
						<label for="vis{$id50}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id50}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='OPPL']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Sykehistorie -->
			<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='TS'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='ANAM'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='ART']">
				<xsl:variable name="id5">
					<xsl:value-of select="concat('TS',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id5}">Sykehistorie</h2>

					<xsl:if test="$VisSykehistorieVisSkjul">
						<label for="vis{$id5}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id5}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='TS']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='ANAM']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
					</div>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='ART']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Funn/undersøkelsesresultat -->
			<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='FU' or child::*[local-name()='Heading']/@V='LR'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='FUNN']">
				<xsl:variable name="id7">
					<xsl:value-of select="concat('FU',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id7}">Funn/undersøkelsesresultat</h2>

					<xsl:if test="$VisResultatVisSkjul">
						<label for="vis{$id7}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id7}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='FU']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='LR']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='FUNN']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='ResultItem']">
							<xsl:if test="position()=1">
								<div class="eh-row-8 md">
									<div class="eh-col-1 md eh-label">Undersøkelse</div>
									<div class="eh-col-1 md eh-label">Funn/resultat</div>
									<xsl:if test="//child::*[local-name()='ResultItem']/child::*[local-name()='DevResultInd']">
										<div class="eh-col-1 md eh-label">Avviksmarkør</div>
									</xsl:if>
									<xsl:if test="//child::*[local-name()='ResultItem']/child::*[local-name()='InvDate']">
										<div class="eh-col-1 md eh-label">Tidspunkt for undersøkelsen</div>
									</xsl:if>
									<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='StartDateTime']">
										<div class="eh-col-1 md eh-label">Starttidspunkt</div>
									</xsl:if>
									<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='EndDateTime']">
										<div class="eh-col-1 md eh-label">Sluttidspunkt</div>
									</xsl:if>
									<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='OrgDate']">
										<div class="eh-col-1 md eh-label">Tidspunkt for opprinnelse</div>
									</xsl:if>
								</div>
							</xsl:if>
							<div class="eh-row-8">
								<xsl:call-template name="ResultItem"/>
							</div>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Forløp og behandling -->
			<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='FO'] or //child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='PROB']">
				<xsl:variable name="id8">
					<xsl:value-of select="concat('FO',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id8}">Forløp&#160;og&#160;behandling</h2>

					<xsl:if test="$VisForlopBehandlingVisSkjul">
						<label for="vis{$id8}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id8}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<div class="eh-row-8">
							<div class="eh-col-1 eh-label">Aktuell problemstilling</div>
						</div>
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='PROB']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
					</div>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='FO']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Legemiddelopplysninger -->
			<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='ME'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='MEDB']">
				<xsl:variable name="id9">
					<xsl:value-of select="concat('ME',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id9}">Legemiddelopplysninger</h2>

					<xsl:if test="$VisMedisineringVisSkjul">
						<label for="vis{$id9}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id9}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='ME']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='MEDB']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='MEDB']/child::*[local-name()='ResultItem']">
							<xsl:call-template name="ResultItem"/> <!-- Bug?? Mangler rad-element for ResultItem -->
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
									<div class="eh-col-2-xs eh-label">Legemiddel</div>
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
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Funksjonsnivå/hjelpetiltak -->
			<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='HJ']">
				<xsl:variable name="id10">
					<xsl:value-of select="concat('HJ',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id10}">Funksjonsnivå/hjelpetiltak</h2>

					<xsl:if test="$VisFunksjonVisSkjul">
						<label for="vis{$id10}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id10}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='HJ']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Sykmelding -->
			<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='SY'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='SYKM']">
				<xsl:variable name="id12">
					<xsl:value-of select="concat('SY',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id12}">Sykmelding</h2>

					<xsl:if test="$VisSykmeldingVisSkjul">
						<label for="vis{$id12}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id12}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='SY']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='SYKM']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Prosedyrer mv. -->
			<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='OPIN' or child::*[local-name()='Type']/@V='MPRS' or child::*[local-name()='Type']/@V='PRS']">
				<xsl:variable name="id60">
					<xsl:value-of select="concat('PRS',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id60}">Prosedyrer&#160;mv.</h2>

					<xsl:if test="$VisProsedyrerVisSkjul">
						<label for="vis{$id60}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id60}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='OPIN' or child::*[local-name()='Type']/@V='MPRS' or child::*[local-name()='Type']/@V='PRS']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Andre kliniske opplysninger -->
			<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='PROG' or child::*[local-name()='Type']/@V='GBEH' or child::*[local-name()='Type']/@V='GOPL' or child::*[local-name()='Type']/@V='SYMP' or child::*[local-name()='Type']/@V='TB' or child::*[local-name()='Type']/@V='US' or child::*[local-name()='Type']/@V='SM']">
				<xsl:variable name="id70">
					<xsl:value-of select="concat('PROG',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id70}">Andre&#160;kliniske&#160;opplysninger</h2>

					<xsl:if test="$VisAndreKliniskeVisSkjul">
						<label for="vis{$id70}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id70}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='PROG' or child::*[local-name()='Type']/@V='GBEH' or child::*[local-name()='Type']/@V='GOPL' or child::*[local-name()='Type']/@V='SYMP' or child::*[local-name()='Type']/@V='TB' or child::*[local-name()='Type']/@V='US' or child::*[local-name()='Type']/@V='SM']/child::*[local-name()='Observation']">
							<xsl:call-template name="eh-Observation"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Familie/sosialt -->
			<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='FA']">
				<xsl:variable name="id13">
					<xsl:value-of select="concat('FA',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id13}">Familie/sosialt</h2>

					<xsl:if test="$VisFamilieVisSkjul">
						<label for="vis{$id13}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id13}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='FA']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Ubesvarte prøver -->
			<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='UP']">
				<xsl:variable name="id15">
					<xsl:value-of select="concat('UP',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id15}">Ubesvarte&#160;prøver</h2>

					<xsl:if test="$VisUbesvarteVisSkjul">
						<label for="vis{$id15}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id15}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='UP']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Tilbakemelding (uspes.) -->
			<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='TB'] or //child::*[local-name()='Event']/child::*[local-name()='Comment'][not(child::*[local-name()='Heading'])]">
				<xsl:variable name="id16">
					<xsl:value-of select="concat('TB',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id16}">Tilbakemelding&#160;(uspes.)</h2>

					<xsl:if test="$VisTilbakemeldingVisSkjul">
						<label for="vis{$id16}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id16}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='TB']">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
						<xsl:for-each select="//child::*[local-name()='Comment'][not(child::*[local-name()='Heading'])]">
							<xsl:call-template name="ReasonAsText-Comment"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for øvrig pasientinformasjon -->
			<xsl:for-each select="child::*[local-name()='Patient']">
				<xsl:if test="child::*[local-name()='BasisForHealthServices'] or child::*[local-name()='Name'] or child::*[local-name()='OffId'] or child::*[local-name()='Sex'] or child::*[local-name()='DateOfBirth'] or child::*[local-name()='PatientPrecaution'] or child::*[local-name()='NeedTranslator'] or child::*[local-name()='CareSituation'] or child::*[local-name()='PatRelperson'] or child::*[local-name()='PatRelInst'] or child::*[local-name()='Consent'] or child::*[local-name()='AdditionalId']">
					<xsl:variable name="id30">
						<xsl:value-of select="concat('Patient',$position)"/>
					</xsl:variable>

					<section>
						<h2 id="{$id30}">Pasient</h2>

						<xsl:if test="$VisOvrigPasientInfoVisSkjul">
							<label for="vis{$id30}" class="VisSkjul">Vis/Skjul</label>
							<input type="checkbox" checked="true" id="vis{$id30}" style="display: none;"/>
						</xsl:if>

						<div class="eh-section">
							<xsl:call-template name="Patient"/>
						</div>
					</section>
				</xsl:if>
			</xsl:for-each>

			<!-- Overskrift og tabell for øvrig informasjon helsetjenesteenheter -->
			<xsl:if test="child::*[local-name()='ServProvider'] | child::*[local-name()='Requester'] | child::*[local-name()='CopyDest'] | .//child::*[local-name()='RelServProvider'] | .//child::*[local-name()='Origin'] | .//child::*[local-name()='RelHCProvider'] | .//child::*[local-name()='PatRelHCP']">
				<xsl:variable name="id31">
					<xsl:value-of select="concat('HCP',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id31}">Kontaktopplysninger</h2>

					<xsl:if test="$VisOvrigHelsetjenesteInfoVisSkjul">
						<label for="vis{$id31}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" checked="true" id="vis{$id31}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section xs">
						<xsl:for-each select="child::*[local-name()='ServProvider']">
							<xsl:call-template name="ServProvider">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:call-template>
							<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#160;</div></div> <!-- separator line when collapsed -->
						</xsl:for-each>
						<xsl:for-each select="child::*[local-name()='Requester']">
							<xsl:call-template name="Requester">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:call-template>
							<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#160;</div></div>
						</xsl:for-each>
						<xsl:for-each select="child::*[local-name()='CopyDest']">
							<xsl:call-template name="CopyDest">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:call-template>
							<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#160;</div></div>
						</xsl:for-each>
						<xsl:for-each select=".//child::*[local-name()='RelServProvider']">
							<xsl:call-template name="RelServProvider">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:call-template>
							<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#160;</div></div>
						</xsl:for-each>
						<xsl:for-each select=".//child::*[local-name()='Origin']">
							<xsl:call-template name="Origin">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:call-template>
							<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#160;</div></div>
						</xsl:for-each>
						<xsl:for-each select=".//child::*[local-name()='RelHCProvider']">
							<xsl:call-template name="RelHCProvider">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:call-template>
							<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#160;</div></div>
						</xsl:for-each>
						<xsl:for-each select=".//child::*[local-name()='PatRelHCP']">
							<xsl:call-template name="PatRelHCP">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:call-template>
							<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#160;</div></div>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for hendelse -->
			<xsl:if test="child::*[local-name()='Event']">
				<xsl:variable name="id32">
					<xsl:value-of select="concat('Event',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id32}">Hendelser</h2>

					<xsl:if test="$VisHendelseVisSkjul">
						<label for="vis{$id32}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" checked="true" id="vis{$id32}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='Event']">
							<xsl:if test="position()=1">
								<div class="eh-row-8 md">
									<div class="eh-col-2 md eh-label">Type</div>
									<xsl:if test="..//child::*[local-name()='EventLocation']">
										<div class="eh-col-1 md eh-label">Sted</div>
									</xsl:if>
									<xsl:if test="..//child::*[local-name()='ReportedEvent']/child::*[local-name()='StartDateTime'] or ..//child::*[local-name()='ReportedEvent']/child::*[local-name()='EndDateTime'] or ..//child::*[local-name()='ExpDuration']">
										<div class="eh-col-1 md eh-label">Tidspunkt</div>
									</xsl:if>
									<xsl:if test="..//child::*[local-name()='AdmOutcome']">
										<div class="eh-col-1 md eh-label">Ut til</div>
									</xsl:if>
									<xsl:if test="..//child::*[local-name()='Priority']">
										<div class="eh-col-1 md eh-label">Prioritet</div>
									</xsl:if>
									<xsl:if test="..//child::*[local-name()='AssRequest']">
										<div class="eh-col-1 md eh-label eh-last-child">Tilknyttet melding/dokument</div>
									</xsl:if>
								</div>
							</xsl:if>
							<xsl:if test="position() &gt; 1 and not(local-name(..)='Event')">
								<div class="eh-row-8 md">
									<div class="eh-col-1 eh-last-child">
										<hr/>
									</div>
								</div>
							</xsl:if>
							<xsl:call-template name="Event"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for referert dokument -->
			<xsl:if test="child::*[local-name()='RefDoc']">
				<xsl:variable name="id40">
					<xsl:value-of select="concat('RefDoc',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id40}">Vedlegg</h2>

					<xsl:if test="$VisRefDokVisSkjul">
						<label for="vis{$id40}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id40}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='RefDoc']">
							<xsl:call-template name="eh-RefDoc"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Overskrift og tabell for Opprinnelig henvisning -->
			<xsl:if test="child::*[local-name()='ServReq']">
				<xsl:variable name="id41">
					<xsl:value-of select="concat('ServReq',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id41}">Opprinnelig&#160;henvisning</h2>

					<xsl:if test="$VisOpprinneligHenvisningVisSkjul">
						<label for="vis{$id41}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" checked="true" id="vis{$id41}" style="display: none;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='ServReq']">
							<xsl:call-template name="ServReq"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>
		</main>
	</xsl:template>


	<!-- Meldingshodet - Dokumentopplysninger -->
	<xsl:template name="Footer"> <!-- Message/ServRprt -->
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
					<xsl:if test="child::*[local-name()='ApprDate']">
						<div class="eh-col-1">
							<div class="eh-label">Melding godkjent</div>
							<div class="eh-field">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='ApprDate']/@V"/>
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
					<xsl:if test="child::*[local-name()='Priority']">
						<div class="eh-col-1">
							<div class="eh-label">Hastegrad</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='Priority']">
									<xsl:call-template name="k-7303"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
					<!-- <xsl:if test="child::*[local-name()='Ack']">
						<div class="eh-col-1">
							<div class="eh-label">Meldingsbekreftelse</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='Ack']">
									<xsl:call-template name="k-7304"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if> -->
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

	<xsl:template name="EgetBunnTillegg"></xsl:template>

	<!-- Klikkbar horisontal meny som leder lenger ned i dokumentet -->
	<xsl:template name="FellesMeny">
		<xsl:param name="position"/>
		<nav id="FellesMeny" class="FellesMeny NoPrint">
			<ul>
				<xsl:if test="//child::*[local-name()='Diagnosis'] or //child::*[local-name()='DiagComment'] or //child::*[local-name()='ReasonAsText'][child::*[local-name()='Heading']/@V='DIAG'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='H' or child::*[local-name()='Type']/@V='B']">
					<li>
						<xsl:variable name="temp1" select="concat('Diagnosis',$position)"/>
						<a href="#{$temp1}">Diagnoser</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='CAVE' or child::*[local-name()='Type']/@V='NB']">
					<li>
						<xsl:variable name="temp2" select="concat('CAVE',$position)"/>
						<a href="#{$temp2}">Kritisk informasjon</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='VU']">
					<li>
						<xsl:variable name="temp6" select="concat('VU',$position)"/>
						<a href="#{$temp6}">Vurdering</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='OP']">
					<li>
						<xsl:variable name="temp11" select="concat('OP',$position)"/>
						<a href="#{$temp11}">Videre&#160;oppfølging</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='UTRED']">
					<li>
						<xsl:variable name="temp17" select="concat('UTRED',$position)"/>
						<a href="#{$temp17}">Forventet&#160;utredning/behandling</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='AI'] or //child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='ÅI']">
					<li>
						<xsl:variable name="temp3" select="concat('AI',$position)"/>
						<a href="#{$temp3}">Årsak&#160;til&#160;innleggelse</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='AH']">
					<li>
						<xsl:variable name="temp4" select="concat('AH',$position)"/>
						<a href="#{$temp4}">Årsak&#160;til&#160;henvisning</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='OPPL']">
					<li>
						<xsl:variable name="temp50" select="concat('OPPL',$position)"/>
						<a href="#{$temp50}">Kliniske&#160;opplysninger</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='TS'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='ANAM']">
					<li>
						<xsl:variable name="temp5" select="concat('TS',$position)"/>
						<a href="#{$temp5}">Sykehistorie</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='FU' or child::*[local-name()='Heading']/@V='LR'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='FUNN']">
					<li>
						<xsl:variable name="temp7" select="concat('FU',$position)"/>
						<a href="#{$temp7}">Funn&#160;og&#160;undersøkelsesresultater</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='FO'] or //child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='PROB']">
					<li>
						<xsl:variable name="temp8" select="concat('FO',$position)"/>
						<a href="#{$temp8}">Forløp&#160;og&#160;behandling</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='ME'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='MEDB']">
					<li>
						<xsl:variable name="temp9" select="concat('ME',$position)"/>
						<a href="#{$temp9}">Medisinering</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='HJ']">
					<li>
						<xsl:variable name="temp10" select="concat('HJ',$position)"/>
						<a href="#{$temp10}">Funksjonsnivå/hjelpetiltak</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='SY'] or //child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='SYKM']">
					<li>
						<xsl:variable name="temp12" select="concat('SY',$position)"/>
						<a href="#{$temp12}">Sykmelding</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='OPIN' or child::*[local-name()='Type']/@V='MPRS' or child::*[local-name()='Type']/@V='PRS']">
					<li>
						<xsl:variable name="temp60" select="concat('PRS',$position)"/>
						<a href="#{$temp60}">Prosedyrer&#160;mv.</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Type']/@V='PROG' or child::*[local-name()='Type']/@V='GBEH' or child::*[local-name()='Type']/@V='GOPL' or child::*[local-name()='Type']/@V='SYMP' or child::*[local-name()='Type']/@V='TB' or child::*[local-name()='Type']/@V='US' or child::*[local-name()='Type']/@V='SM']">
					<li>
						<xsl:variable name="temp70" select="concat('PROG',$position)"/>
						<a href="#{$temp70}">Andre&#160;kliniske&#160;opplysninger</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='FA']">
					<li>
						<xsl:variable name="temp13" select="concat('FA',$position)"/>
						<a href="#{$temp13}">Familie/sosialt</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='IP']">
					<li>
						<xsl:variable name="temp14" select="concat('IP',$position)"/>
						<a href="#{$temp14}">Informasjon&#160;til&#160;pasient/pårørende</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='UP']">
					<li>
						<xsl:variable name="temp15" select="concat('UP',$position)"/>
						<a href="#{$temp15}">Ubesvarte&#160;prøver</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Comment'][child::*[local-name()='Heading']/@V='TB']">
					<li>
						<xsl:variable name="temp16" select="concat('TB',$position)"/>
						<a href="#{$temp16}">Tilbakemelding&#160;(uspes.)</a>
					</li>
				</xsl:if>
				<xsl:for-each select="//child::*[local-name()='Patient']">
					<xsl:if test="child::*[local-name()='Name'] or child::*[local-name()='OffId'] or child::*[local-name()='Sex'] or child::*[local-name()='DateOfBirth'] or child::*[local-name()='PatientPrecaution'] or child::*[local-name()='PatientRelParty'] or child::*[local-name()='AdditionalId']">
						<li>
							<xsl:variable name="temp30" select="concat('Patient',$position)"/>
							<a href="#{$temp30}">Pasient</a>
						</li>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="child::*[local-name()='ServProvider'] or child::*[local-name()='Requester'] or child::*[local-name()='CopyDest'] or .//child::*[local-name()='RelServProvider'] or .//child::*[local-name()='Origin'] or .//child::*[local-name()='RelHCProvider'] or .//child::*[local-name()='PatRelHCP']">
					<li>
						<xsl:variable name="temp31" select="concat('HCP',$position)"/>
						<a href="#{$temp31}">Kontaktopplysninger</a>
					</li>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Event']">
					<li>
						<xsl:variable name="temp32" select="concat('Event',$position)"/>
						<a href="#{$temp32}">Hendelser</a>
					</li>
				</xsl:if>
				<xsl:if test="child::*[local-name()='RefDoc']">
					<li>
						<xsl:variable name="temp40" select="concat('RefDoc',$position)"/>
						<a href="#{$temp40}">Vedlegg</a>
					</li>
				</xsl:if>
				<xsl:if test="child::*[local-name()='ServReq']">
					<li>
						<xsl:variable name="temp41" select="concat('ServReq',$position)"/>
						<a href="#{$temp41}">Opprinnelig&#160;henvisning</a>
					</li>
				</xsl:if>
			</ul>
		</nav>
	</xsl:template>


	<!-- Visning av Tilbakemelding -->
	<xsl:template name="ServRprt">
		<xsl:if test="//child::*[local-name()='ReportedEvent']/child::*[local-name()='StartDateTime'] or //child::*[local-name()='ReportedEvent']/child::*[local-name()='EndDateTime'] or //child::*[local-name()='RelServProvider']">
			<div class="eh-row-4">
				<xsl:for-each select="//child::*[local-name()='ReportedEvent']">
					<xsl:if test="child::*[local-name()='StartDateTime'] and position()=1">
						<div class="eh-col-1">
							<div class="eh-label">Innlagt</div>
							<div class="eh-field">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='EndDateTime'] and position()=last()">
						<div class="eh-col-1">
							<div class="eh-label">Utskrevet</div>
							<div class="eh-field">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="//child::*[local-name()='RelServProvider']//child::*[local-name()='HCProf']">
					<xsl:if test="position()=1">
						<div class="eh-col-1 eh-last-child">
							<div class="eh-label">Ansvarlig</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='Type']">
									<xsl:call-template name="k-9060"/>&#160;
								</xsl:for-each>
								<xsl:value-of select="child::*[local-name()='Name']"/>
							</div>
						</div>
					</xsl:if>
				</xsl:for-each>
			</div>
		</xsl:if>
	</xsl:template>


	<!-- Visning av Henvisning -->
	<xsl:template name="ServReq">
		<div class="eh-row-5">
			<xsl:if test="child::*[local-name()='MsgDescr']">
				<div class="eh-col-1">
					<div class="eh-label">Type</div>
					<div class="eh-field"><xsl:value-of select="child::*[local-name()='MsgDescr']/@DN"/></div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='IssueDate']">
				<div class="eh-col-1">
					<div class="eh-label">Utstedt</div>
					<div class="eh-field">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']/@V"/>
							<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='ReceiptDate']">
				<div class="eh-col-1">
					<div class="eh-label">Mottatt</div>
					<div class="eh-field">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="child::*[local-name()='ReceiptDate']/@V"/>
							<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='ReqComment']">
				<div class="eh-col-1">
					<div class="eh-label">Kommentar</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='ReqComment']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
		<!-- Endring pr 22.05.2017 -->
		<!-- Finn antall diagnoser for å lage en tittel som er Diagnose/Diagnoser -->
		<div class="eh-row-5">
			<xsl:choose>
				<xsl:when test="count(child::*[local-name()='Diagnosis'])>1">
					<div class="eh-col-1">
						<div class="eh-label">Diagnoser:</div>
						<xsl:for-each select="child::*[local-name()='Diagnosis']">
							<div class="eh-col-1">
								<div class="eh-field">
									<xsl:value-of select="child::*[local-name()='Concept']/@DN"/>,&#160;
									<xsl:value-of select="child::*[local-name()='Concept']/@V"/>&#160;
									<xsl:if test="contains(child::*[local-name()='Concept']/@S, '7170')">(ICPC)&#160;</xsl:if>
									<xsl:if test="contains(child::*[local-name()='Concept']/@S, '7110')">(ICD-10)&#160;</xsl:if>
									<xsl:for-each select="child::*[local-name()='Modifier']">
										<xsl:value-of select="child::*[local-name()='Value']/@V"/>,&#160;
										<xsl:value-of select="child::*[local-name()='Value']/@DN"/>&#160;
									</xsl:for-each>
								</div>
							</div>
						</xsl:for-each>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="eh-col-1">
						<div class="eh-label">Diagnose:</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Diagnosis']">
								<xsl:value-of select="child::*[local-name()='Concept']/@DN"/>,&#160;
								<xsl:value-of select="child::*[local-name()='Concept']/@V"/>&#160;
								<xsl:if test="contains(child::*[local-name()='Concept']/@S, '7170')">(ICPC)&#160;</xsl:if>
								<xsl:if test="contains(child::*[local-name()='Concept']/@S, '7110')">(ICD-10)&#160;</xsl:if>
								<xsl:for-each select="child::*[local-name()='Modifier']">
									<xsl:value-of select="child::*[local-name()='Value']/@V"/>,&#160;
									<xsl:value-of select="child::*[local-name()='Value']/@DN"/>&#160;
								</xsl:for-each>
							</xsl:for-each>
						</div>
					</div>
				</xsl:otherwise>
			</xsl:choose>
		</div>

			<!-- Endring pr 22.05.2017  SLUTT-->
		<xsl:for-each select="child::*[local-name()='ReasonAsText']">
			<xsl:call-template name="ReasonAsText-Comment"/>
		</xsl:for-each>
	</xsl:template>


	<!-- Visning av Diagnose -->
	<xsl:template name="Diagnosis-DiagComment-CodedDescr-CodedComment">
		<xsl:param name="addColumn"/>

		<xsl:variable name="HovedDiagnose">
			<xsl:choose>
				<xsl:when test="../../child::*[local-name()='Type']/@V='H'">bold</xsl:when>
				<xsl:otherwise>normal</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="eh-col-2">
			<div class="eh-field" style="font-weight:{$HovedDiagnose}">
			    <xsl:for-each select="child::*[local-name()='Concept']"></xsl:for-each>
				<xsl:if test="child::*[local-name()='Concept']/@DN or child::*[local-name()='Concept']/@OT">
					<xsl:for-each select="child::*[local-name()='Concept']">
						<xsl:call-template name="k-dummy"/>
					</xsl:for-each>
				</xsl:if>
				<xsl:for-each select="child::*[local-name()='Modifier']">,&#160;<xsl:value-of select="child::*[local-name()='Value']/@DN"/></xsl:for-each>
				<xsl:value-of select="'. '"/>
				<xsl:value-of select="child::*[local-name()='Concept']/@V"/>&#160;
				<xsl:if test="contains(child::*[local-name()='Concept']/@S, '7170')">(ICPC)</xsl:if>
				<xsl:if test="contains(child::*[local-name()='Concept']/@S, '7110')">(ICD-10)</xsl:if>
				<xsl:for-each select="child::*[local-name()='Modifier']">,&#160;<xsl:value-of select="child::*[local-name()='Value']/@V"/></xsl:for-each>
			</div>
		</div>
	</xsl:template>


	<!-- Visning av Begrunnelse for / kommentar til henvisningen -->
	<xsl:template name="ReasonAsText-Comment">
		<div class="eh-row-4">
			<div class="eh-col-1 eh-last-child">
				<xsl:if test="local-name(.)='ReasonAsText'">
					<div class="eh-label">
						<xsl:for-each select="child::*[local-name()='Heading']">
							<xsl:call-template name="k-8231"/>
						</xsl:for-each>
						<xsl:if test="not(child::*[local-name()='Heading'])">Begrunnelse&#160;(uspes.)</xsl:if>
					</div>
				</xsl:if>
				<div class="eh-field">
					<xsl:for-each select="child::*[local-name()='TextResultValue']"> <!-- type="anyType" eller "kith:ST" -->
						<div xmlns="http://www.w3.org/1999/xhtml">
							<xsl:choose>
								<xsl:when test="count(child::*)=0">
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="."/>
									</xsl:call-template>&#160;
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy-of select="node()"/>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</xsl:for-each>
					<xsl:for-each select="child::*[local-name()='TextCode']">
						<div>
							<xsl:choose>
								<xsl:when test="@DN"><xsl:value-of select="@DN"/>&#160;</xsl:when>
								<xsl:when test="@OT"><xsl:value-of select="@OT"/>&#160;</xsl:when>
								<xsl:when test="@V"><xsl:value-of select="@V"/>&#160;<xsl:choose>
										<xsl:when test="contains(@S,'7010')">(SNOMED)</xsl:when>
										<xsl:when test="contains(@S,'7230')">(NKKKL)</xsl:when>
										<xsl:when test="contains(@S,'7240')">(NORAKO)</xsl:when>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>
						</div>
					</xsl:for-each>
				</div>
			</div>
		</div>
	</xsl:template>


	<!-- Visning av Annen klinisk opplysning -->
	<!-- Deprecated : se fellskomponenter/eh-komponent1.xsl : eh-Observation -->
	<xsl:template name="Observation"> <!-- Message/ServRprt/Event/InfItem/Observation (v1.0, v1.1, v1.2) -->
		<xsl:if test="child::*[local-name()='Description'] or child::*[local-name()='Comment'] or ../child::*[local-name()='StartDateTime'] or ../child::*[local-name()='EndDateTime'] or ../child::*[local-name()='OrgDate']">
			<div class="eh-row">
				<div class="eh-col-1">
					<xsl:for-each select="child::*[local-name()='Description']"> <!-- type="anyType" eller "kith:ST" -->
						<xsl:choose>
							<xsl:when test="count(child::*)=0">
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="."/>
								</xsl:call-template>&#160;
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="node()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					<xsl:if test="child::*[local-name()='Comment']">
						<div>
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Comment']"/>
							</xsl:call-template>
						</div>
					</xsl:if>
				</div>
				<xsl:if test="../child::*[local-name()='StartDateTime'] or ../child::*[local-name()='EndDateTime'] or ../child::*[local-name()='OrgDate']">
					<div class="eh-col-1 eh-last-child">
						<xsl:if test="../child::*[local-name()='StartDateTime']">
							<div>Start:&#160;
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="../child::*[local-name()='StartDateTime']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</div>
						</xsl:if>
						<xsl:if test="../child::*[local-name()='EndDateTime']">
							<div>Slutt:&#160;
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="../child::*[local-name()='EndDateTime']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</div>
						</xsl:if>
						<xsl:if test="../child::*[local-name()='OrgDate']">
							<div>Opprinnelse:&#160;
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="../child::*[local-name()='OrgDate']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</div>
						</xsl:if>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:for-each select="child::*[local-name()='CodedDescr']">
			<div class="eh-row-4">
				<xsl:call-template name="Diagnosis-DiagComment-CodedDescr-CodedComment"/>
			</div>
		</xsl:for-each>
	</xsl:template>


	<!-- Visning av Undersøkelsesresultat -->
	<xsl:template name="ResultItem"> <!-- Message/ServRprt/Event/InfItem/ResultItem (v1.0, v1.1, v1.2) -->
		<!-- merk: rad-element ikke inkludert her. -->
		<div class="eh-col-1 eh-field">
			<div class="eh-label xs">Undersøkelse</div>
			<div class="eh-text">
				<xsl:for-each select="child::*[local-name()='ClinInv']">
					<div>
						<xsl:for-each select="child::*[local-name()='Id']">
							<xsl:call-template name="k-dummy"/>
						</xsl:for-each>
					</div>
					<xsl:for-each select="child::*[local-name()='Spec']">
						<div>
							<b>Spesifisert:</b>&#160;
							<xsl:call-template name="k-dummy"/>
						</div>
					</xsl:for-each>
				</xsl:for-each>
			</div>
		</div>
		<div class="eh-col-1 eh-field">
			<div class="eh-label xs">Avviksmarkør</div>
			<div class="eh-text">
				<xsl:for-each select="child::*[local-name()='Interval']">
					<xsl:if test="child::*[local-name()='Low']"><b>Nedre:</b>&#160;<xsl:value-of select="child::*[local-name()='Low']/@V"/><xsl:value-of select="child::*[local-name()='Low']/@U"/>&#160;</xsl:if>
					<xsl:if test="child::*[local-name()='High']"><b>Øvre:</b>&#160;<xsl:value-of select="child::*[local-name()='High']/@V"/><xsl:value-of select="child::*[local-name()='High']/@U"/>&#160;</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='DateResult']">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateResultValue']/@V"/>
						<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
					</xsl:call-template>
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='NumResult']">
					<xsl:for-each select="child::*[local-name()='ArithmeticComp']">
						<xsl:call-template name="k-8239"/>&#160;
					</xsl:for-each>
					<xsl:value-of select="child::*[local-name()='NumResultValue']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='NumResultValue']/@U"/>&#160;
					<xsl:for-each select="../child::*[local-name()='DevResultInd']">
						<b style="color:red;"><xsl:call-template name="k-8244"/></b>
					</xsl:for-each>
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='TextResult']/child::*[local-name()='Result']">
					<xsl:if test="child::*[local-name()='TextResultValue']">
						<div><xsl:call-template name="line-breaks"><xsl:with-param name="text" select="child::*[local-name()='TextResultValue']"/></xsl:call-template></div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='TextCode']">
						<div>
							<xsl:call-template name="k-dummy"/>
						</div>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="child::*[local-name()='Comment']">
					<div>
						<b>Kommentar:</b>&#160;<xsl:call-template name="line-breaks"><xsl:with-param name="text" select="child::*[local-name()='Comment']"/></xsl:call-template>
					</div>
				</xsl:if>
			</div>
		</div>
		<xsl:if test="//child::*[local-name()='ResultItem']/child::*[local-name()='InvDate']">
			<div class="eh-col-1 eh-field">
				<div class="eh-label xs">Tidspunkt for undersøkelsen</div>
				<div class="eh-text">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="child::*[local-name()='InvDate']/@V"/>
						<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
					</xsl:call-template>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='StartDateTime']">
			<div class="eh-col-1 eh-field">
				<div class="eh-label xs">Starttidspunkt</div>
				<div class="eh-text">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="../child::*[local-name()='StartDateTime']/@V"/>
						<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
					</xsl:call-template>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='EndDateTime']">
			<div class="eh-col-1 eh-field">
				<div class="eh-label xs">Sluttidspunkt</div>
				<div class="eh-text">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="../child::*[local-name()='EndDateTime']/@V"/>
						<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
					</xsl:call-template>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='OrgDate']">
			<div class="eh-col-1 eh-field eh-last-child">
				<div class="eh-label xs">Tidspunkt for opprinnelse</div>
				<div class="eh-text">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="../child::*[local-name()='OrgDate']/@V"/>
						<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
					</xsl:call-template>
				</div>
			</div>
		</xsl:if>
	</xsl:template>


	<!-- Visning av Medikamentell behandling -->
	<!-- Deprecated : se fellskomponenter/eh-komponent1.xsl : eh-Medication -->
	<xsl:template name="Medication">
		<div class="eh-col-1">
			<xsl:for-each select="child::*[local-name()='DrugId']">
				<xsl:call-template name="k-dummy"/>
			</xsl:for-each>
		</div>
		<div class="eh-col-1">
			<xsl:for-each select="child::*[local-name()='Status']">
				<xsl:call-template name="k-7307"/>&#160;
			</xsl:for-each>
		</div>
		<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='UnitDose'] or //child::*[local-name()='Medication']/child::*[local-name()='QuantitySupplied']">
			<div class="eh-col-1">
				<xsl:if test="child::*[local-name()='UnitDose']">
					<xsl:value-of select="child::*[local-name()='UnitDose']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='UnitDose']/@U"/>
					<xsl:if test="child::*[local-name()='QuantitySupplied']">&#160;x&#160;</xsl:if>
				</xsl:if>
				<xsl:if test="child::*[local-name()='QuantitySupplied']">
					<xsl:value-of select="child::*[local-name()='QuantitySupplied']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='QuantitySupplied']/@U"/>
				</xsl:if>&#160;
			</div>
		</xsl:if>
		<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='DosageText'] or //child::*[local-name()='Medication']/child::*[local-name()='IntendedDuration']">
			<div class="eh-col-1">
				<xsl:if test="child::*[local-name()='DosageText']">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="child::*[local-name()='DosageText']"/>
					</xsl:call-template>
				</xsl:if>&#160;
				<xsl:if test="child::*[local-name()='IntendedDuration']">&#160;/&#160;<xsl:value-of select="child::*[local-name()='IntendedDuration']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='IntendedDuration']/@U"/></xsl:if>
				<xsl:if test="not(child::*[local-name()='DosageText']) and not(child::*[local-name()='IntendedDuration'])">&#160;</xsl:if>
			</div>
		</xsl:if>
		<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='Comment']">
			<div class="eh-col-1">
				<xsl:call-template name="line-breaks">
					<xsl:with-param name="text" select="child::*[local-name()='Comment']"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Medication']]/child::*[local-name()='StartDateTime']">
			<div class="eh-col-1">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../child::*[local-name()='StartDateTime']/@V"/>
					<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Medication']]/child::*[local-name()='EndDateTime']">
			<div class="eh-col-1">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../child::*[local-name()='EndDateTime']/@V"/>
					<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Medication']]/child::*[local-name()='OrgDate']">
			<div class="eh-col-1">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../child::*[local-name()='OrgDate']/@V"/>
					<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
				</xsl:call-template>
			</div>
		</xsl:if>
	</xsl:template>


	<!-- Visning av Pasient -->
	<xsl:template name="Patient">
		<xsl:if test="child::*[local-name()='Name'] or child::*[local-name()='OffId'] or child::*[local-name()='Sex'] or child::*[local-name()='DateOfBirth'] or child::*[local-name()='AdditionalId']">
			<div class="eh-row-8">
				<div class="eh-col-1 eh-label">Pasientinfo</div>
			</div>
			<div class="eh-row-8">
				<xsl:if test="child::*[local-name()='Name']">
					<div class="eh-col-1 md eh-label">Navn</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='OffId']">
					<div class="eh-col-1 md eh-label">
						<xsl:choose>
							<xsl:when test="not($Anonymisert)">
								<xsl:for-each select="child::*[local-name()='TypeOffId']">
									<xsl:call-template name="k-8116"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>Fødselsnummer</xsl:otherwise>
						</xsl:choose>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Sex']">
					<div class="eh-col-1 md eh-label">Kjønn</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='DateOfBirth']">
					<div class="eh-col-1 md eh-label">Fødsels&#173;dag</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='DateOfDeath']">
					<div class="eh-col-1 md eh-label">Døds&#173;dag</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='AdditionalId']">
					<div class="eh-col-1 md eh-label">Tilleggs-Id</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Address']">
					<div class="eh-col-1 md eh-label">Adresse</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Address']/child::*[local-name()='TeleAddress']">
					<div class="eh-col-1 md eh-label eh-last-child">Telefon</div>
				</xsl:if>
			</div>
			<div class="eh-row-8">
				<xsl:if test="child::*[local-name()='Name']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Navn</div>
						<div class="eh-text">
							<xsl:choose>
								<xsl:when test="not($Anonymisert)">
									<xsl:value-of select="child::*[local-name()='Name']"/>
								</xsl:when>
								<xsl:otherwise>Gundersen,&#160;Roland</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='OffId']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">
							<xsl:for-each select="child::*[local-name()='TypeOffId']">
								<xsl:call-template name="k-8116"/>&#160;
							</xsl:for-each>
						</div>
						<div class="eh-text">
							<xsl:choose>
								<xsl:when test="not($Anonymisert)">
									<xsl:value-of select="child::*[local-name()='OffId']"/>
								</xsl:when>
								<xsl:otherwise>15076500565</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Sex']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Kjønn</div>
						<div class="eh-text">
							<xsl:choose>
								<xsl:when test="not($Anonymisert)">
									<xsl:for-each select="child::*[local-name()='Sex']">
										<xsl:call-template name="k-3101"/>&#160;
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>Mann</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='DateOfBirth']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Fødsels&#173;dag</div>
						<div class="eh-text">
							<xsl:choose>
								<xsl:when test="not($Anonymisert)">
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateOfBirth']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>15.07.65</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='DateOfDeath']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Døds&#173;dag</div>
						<div class="eh-text">
							<xsl:choose>
								<xsl:when test="not($Anonymisert)">
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateOfDeath']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>&#160;</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='AdditionalId']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Tilleggs-Id</div>
						<div class="eh-text">
							<xsl:choose>
								<xsl:when test="not($Anonymisert)">
									<xsl:for-each select="child::*[local-name()='AdditionalId']">
										<xsl:if test="child::*[local-name()='Type']"><b><xsl:value-of select="child::*[local-name()='Type']/@V"/>:</b>&#160;</xsl:if>
										<xsl:value-of select="child::*[local-name()='Id']"/>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>&#160;</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Address']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Adresse</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='Address']">
								<b><xsl:call-template name="AddressKey"/>&#173;</b>
								<xsl:call-template name="AddressValue"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Address']/child::*[local-name()='TeleAddress']">
					<div class="eh-col-1 eh-last-child eh-field">
						<div class="eh-label xs">Telefon</div>
						<div class="eh-text">
							<xsl:value-of select="substring-after(child::*[local-name()='Address']/child::*[local-name()='TeleAddress']/@V, ':')"/>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:for-each select="child::*[local-name()='PatientPrecaution']">
			<xsl:if test="not($Anonymisert)">
				<xsl:if test="position()=1">
					<xsl:if test="../child::*[local-name()='Sex'] or ../child::*[local-name()='DateOfBirth'] or ../child::*[local-name()='AdditionalId']">
						<div class="eh-row-8 md">
							<div class="eh-col-1 eh-last-child">
								<hr/>
							</div>
						</div>
					</xsl:if>
					<div class="eh-row-8">
						<div class="eh-col-1 eh-label">Advarsel til avsender</div>
						<xsl:if test="..//child::*[local-name()='PatientPrecaution']/child::*[local-name()='Precaution']">
							<div class="eh-col-1 md eh-label">Advarsel</div>
						</xsl:if>
						<xsl:if test="..//child::*[local-name()='PatientPrecaution']/child::*[local-name()='StartDateTime']">
							<div class="eh-col-1 md eh-label">Start&#173;tidspunkt</div>
						</xsl:if>
						<xsl:if test="..//child::*[local-name()='PatientPrecaution']/child::*[local-name()='EndDateTime']">
							<div class="eh-col-1 md eh-label">Sluttidspunkt</div>
						</xsl:if>
					</div>
				</xsl:if>
			</xsl:if>
			<div class="eh-row-8">
				<div class="eh-col-1 md eh-label">&#160;</div>
				<xsl:if test="..//child::*[local-name()='PatientPrecaution']/child::*[local-name()='Precaution']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Advarsel</div>
						<div class="eh-text">
							<xsl:value-of select="child::*[local-name()='Precaution']"/>&#160;
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatientPrecaution']/child::*[local-name()='StartDateTime']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Starttidspunkt</div>
						<div class="eh-text">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='PatientPrecaution']/child::*[local-name()='EndDateTime']">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Sluttidspunkt</div>
						<div class="eh-text">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='PatientRelParty']">
			<xsl:if test="not($Anonymisert)">
				<xsl:if test="position()=1">
					<xsl:if test="../child::*[local-name()='Sex'] or ../child::*[local-name()='DateOfBirth'] or ../child::*[local-name()='AdditionalId'] or ../child::*[local-name()='PatientPrecaution']">
						<div class="eh-row-8 md">
							<div class="eh-col-1 eh-last-child">
								<hr/>
							</div>
						</div>
					</xsl:if>
					<div class="eh-row-8">
						<div class="eh-col-1 eh-label">Pasientrelatert part</div>
						<xsl:if test="..//child::*[local-name()='PatientRelParty']/child::*[local-name()='Relation']">
							<div class="eh-col-1 md eh-label">Relasjon</div>
						</xsl:if>
						<xsl:if test="..//child::*[local-name()='PatientRelParty']/child::*[local-name()='Name']">
							<div class="eh-col-1 md eh-label">Navn</div>
						</xsl:if>
						<xsl:if test="..//child::*[local-name()='PatientRelParty']/child::*[local-name()='RelPartyOffId']">
							<div class="eh-col-1 md eh-label">Fødselsnummer</div>
						</xsl:if>
						<xsl:if test="..//child::*[local-name()='PatientRelParty']/child::*[local-name()='Address']">
							<div class="eh-col-1 md eh-label eh-last-child">Adresse</div>
						</xsl:if>
					</div>
				</xsl:if>
				<div class="eh-row-8">
					<div class="eh-col-1 md eh-label">&#160;</div>
					<xsl:if test="..//child::*[local-name()='PatientRelParty']/child::*[local-name()='Relation']">
						<div class="eh-col-1 eh-field">
							<div class="eh-label xs">Relasjon</div>
							<div class="eh-text">
								<xsl:for-each select="child::*[local-name()='Relation']">
									<xsl:call-template name="k-7317"/>&#160;
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatientRelParty']/child::*[local-name()='Name']">
						<div class="eh-col-1 eh-field">
							<div class="eh-label xs">Navn</div>
							<div class="eh-text">
								<xsl:value-of select="child::*[local-name()='Name']"/>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatientRelParty']/child::*[local-name()='RelPartyOffId']">
						<div class="eh-col-1 eh-field">
							<div class="eh-label xs">Fødselsnummer</div>
							<div class="eh-text">
								<xsl:value-of select="child::*[local-name()='RelPartyOffId']"/>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="..//child::*[local-name()='PatientRelParty']/child::*[local-name()='Address']">
						<div class="eh-col-1 eh-last-child eh-field">
							<div class="eh-label xs">Adresse</div>
							<div class="eh-text">
								<xsl:for-each select="child::*[local-name()='Address']">
									<b><xsl:call-template name="AddressKey"/>&#173;</b>
									<xsl:call-template name="AddressValue"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
				</div>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<!-- Visning av Hendelse -->
	<xsl:template name="Event">
		<div class="eh-row-8">
			<div class="eh-col-2 eh-field">
				<div class="eh-label xs">Type</div>
				<div class="eh-text">
					<b>
						<xsl:if test="local-name(..)='Event'">Del-hendelse:&#160;</xsl:if>
						<xsl:for-each select="child::*[local-name()='Service']/child::*[local-name()='AdmCat']">
							<xsl:call-template name="k-8240"/>&#160;
						</xsl:for-each>
					</b>
					<xsl:if test="child::*[local-name()='ServType']/@V != 'N'">
						<div>
							<b>Tjenestetype:&#160;</b>
							<xsl:for-each select="child::*[local-name()='ServType']">
								<xsl:call-template name="k-7309"/>&#160;
							</xsl:for-each>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='Recipient']/@V != '1'">
						<div>
							(<xsl:for-each select="child::*[local-name()='Recipient']">
								<xsl:call-template name="k-8250"/>
							</xsl:for-each>)
						</div>
					</xsl:if>
				</div>
			</div>
			<xsl:if test="..//child::*[local-name()='EventLocation']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Sted</div>
					<div class="eh-text">
						<xsl:if test="child::*[local-name()='EventLocation']/child::*[local-name()='Location']/child::*[local-name()='Inst']">
							<div>
								<xsl:if test="child::*[local-name()='EventLocation']/child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Name']">
									<xsl:value-of select="child::*[local-name()='EventLocation']/child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Name']"/>&#160;
								</xsl:if>
								<xsl:if test="child::*[local-name()='EventLocation']/child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Name'] and child::*[local-name()='EventLocation']/child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Dept']/child::*[local-name()='Name']">-&#160;</xsl:if>
								<xsl:if test="child::*[local-name()='EventLocation']/child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Dept']/child::*[local-name()='Name']">
									<xsl:value-of select="child::*[local-name()='EventLocation']/child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Dept']/child::*[local-name()='Name']"/>&#160;
								</xsl:if>
								<xsl:if test="child::*[local-name()='EventLocation']/child::*[local-name()='Location']/child::*[local-name()='SubLocation']/child::*[local-name()='Place']">
									<xsl:value-of select="child::*[local-name()='EventLocation']/child::*[local-name()='Location']/child::*[local-name()='SubLocation']/child::*[local-name()='Place']"/>&#160;
								</xsl:if>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='EventLocation']/child::*[local-name()='Role']">
							<div>
								<b>Rolle:&#160;</b>
								<xsl:for-each select="child::*[local-name()='EventLocation']/child::*[local-name()='Role']">
									<xsl:call-template name="k-8251"/>&#160;
								</xsl:for-each>
								<xsl:for-each select="child::*[local-name()='EventLocation']/child::*[local-name()='Location']/child::*[local-name()='SubLocation']/child::*[local-name()='Type']">
									<xsl:call-template name="k-8242"/>&#160;
								</xsl:for-each>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='EventLocation']/child::*[local-name()='Location']/child::*[local-name()='Address']">
							<div>
								<xsl:for-each select="child::*[local-name()='EventLocation']/child::*[local-name()='Location']/child::*[local-name()='Address']">
									<b><xsl:call-template name="AddressKey"/>&#173;</b>
									<xsl:call-template name="AddressValue"/>
								</xsl:for-each>
							</div>
						</xsl:if>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='ReportedEvent']/child::*[local-name()='StartDateTime'] or ..//child::*[local-name()='ReportedEvent']/child::*[local-name()='EndDateTime'] or ..//child::*[local-name()='ExpDuration']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Tidspunkt</div>
					<div class="eh-text">
						<xsl:if test="child::*[local-name()='ReportedEvent']/child::*[local-name()='StartDateTime']">
							<b>Start: </b>
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='ReportedEvent']/child::*[local-name()='StartDateTime']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="child::*[local-name()='ReportedEvent']/child::*[local-name()='EndDateTime']">
							<b>Slutt: </b>
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='ReportedEvent']/child::*[local-name()='EndDateTime']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="child::*[local-name()='EventLocation']/child::*[local-name()='StartDateTime'] or child::*[local-name()='EventLocation']/child::*[local-name()='EndDateTime']">
							<div>
								<xsl:if test="child::*[local-name()='EventLocation']/child::*[local-name()='StartDateTime']">
									<b>Lokasjonstart: </b>
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='EventLocation']/child::*[local-name()='StartDateTime']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="child::*[local-name()='EventLocation']/child::*[local-name()='EndDateTime']">
									<b>Lokasjonslutt: </b>
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='EventLocation']/child::*[local-name()='EndDateTime']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:if>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='ExpDuration']">
							<div>
								<b>Forventet varighet: </b>
								<xsl:value-of select="child::*[local-name()='ExpDuration']/@V"/><xsl:value-of select="child::*[local-name()='ExpDuration']/@U"/>
							</div>
						</xsl:if>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='AdmOutcome']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Ut til</div>
					<div class="eh-text">
						<xsl:for-each select="child::*[local-name()='AdmOutcome']">
							<xsl:call-template name="k-7300"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='Priority']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Prioritet</div>
					<div class="eh-text">
						<xsl:for-each select="child::*[local-name()='Priority']">
							<xsl:call-template name="k-8304"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='AssRequest']">
				<div class="eh-col-1 eh-last-child eh-field">
					<div class="eh-label xs">Tilknyttet melding/dokument</div>
					<div class="eh-text">
						<xsl:for-each select="child::*[local-name()='AssRequest']/child::*[local-name()='MsgType']">
							<xsl:call-template name="k-7315"/>
						</xsl:for-each>
						<xsl:if test="child::*[local-name()='AssRequest']/child::*[local-name()='IssueDate']">
							<div>
								<b>Utstedt: </b>
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='AssRequest']/child::*[local-name()='IssueDate']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</div>
						</xsl:if>
					</div>
				</div>
			</xsl:if>
		</div>
		<!-- Id (Id) er valgt utelatt -->
	</xsl:template>


	<!-- Visning av Tjenesteyter -->
	<xsl:template name="ServProvider">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label eh-last-child h3">Avsender<xsl:if test="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']"> - Spesialitet:&#160;<xsl:for-each select="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']">
						<xsl:choose>
							<xsl:when test="contains(@S, '7426')">
								<xsl:call-template name="k-7426"/>
							</xsl:when>
							<xsl:when test="contains(@S, '8451')">
								<xsl:call-template name="k-8451"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="k-dummy"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>


	<!-- Visning av Henvisende instans -->
	<xsl:template name="Requester">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label eh-last-child h3">Mottaker<xsl:if test="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']"> - Spesialitet:&#160;<xsl:for-each select="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']">
						<xsl:choose>
							<xsl:when test="contains(@S, '7426')">
								<xsl:call-template name="k-7426"/>
							</xsl:when>
							<xsl:when test="contains(@S, '8451')">
								<xsl:call-template name="k-8451"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="k-dummy"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>


	<!-- Visning av Kopimottaker -->
	<xsl:template name="CopyDest">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label eh-last-child h3">Kopimottaker<xsl:if test="child::*[local-name()='CopyDestRole']/child::*[local-name()='MsgType']"> - kopi&#160;av:&#160;<xsl:for-each select="child::*[local-name()='CopyDestRole']/child::*[local-name()='MsgType']">
						<xsl:call-template name="k-8279"/>
					</xsl:for-each>
				</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>


	<!-- Visning av Tilknyttet tjeneteyter -->
	<xsl:template name="RelServProvider">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label eh-last-child h3">
				<xsl:for-each select="child::*[local-name()='Relation']">
					<xsl:call-template name="k-8254"/>
				</xsl:for-each>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>


	<!-- Visning av Opprinnelse til klinisk opplysning -->
	<xsl:template name="Origin">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label eh-last-child h3">Opprinnelse&#160;til&#160;klinisk&#160;opplysning<xsl:if test="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']"> - Spesialitet:&#160;<xsl:for-each select="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']">
						<xsl:choose>
							<xsl:when test="contains(@S, '7426')">
								<xsl:call-template name="k-7426"/>
							</xsl:when>
							<xsl:when test="contains(@S, '8451')">
								<xsl:call-template name="k-8451"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="k-dummy"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>


	<!-- Visning av Tilknyttet klinisk tjenesteyter -->
	<xsl:template name="RelHCProvider">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label eh-last-child h3">
				<xsl:for-each select="child::*[local-name()='Relation']">
					<xsl:call-template name="k-7318"/>
				</xsl:for-each>
			</div>
		</div>
		<!-- Rolle (Role) er valgt utelatt -->
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>


	<!-- Visning av Tilknyttet klinisk tjenesteyter -->
	<xsl:template name="PatRelHCP">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label eh-last-child h3">
				<xsl:for-each select="child::*[local-name()='Relation']">
					<xsl:call-template name="k-8254"/>
				</xsl:for-each>
				<xsl:if test="child::*[local-name()='StartDateTime'] or child::*[local-name()='EndDateTime']">&#160;Tidsrom:&#160;<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']/@V"/>
						<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
					</xsl:call-template>&#160;-:&#160;<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']/@V"/>
						<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
					</xsl:call-template>&#160;
				</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
		<!-- Rolle (Role) er valgt utelatt -->
	</xsl:template>


	<!-- Visning av Helsetjenesteenhet -->
	<xsl:template name="HCP">
		<xsl:param name="col"/>
		<xsl:for-each select="child::*[local-name()='Inst']">
			<div class="eh-row-4">
				<xsl:call-template name="Inst">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Inst']/child::*[local-name()='Dept']">
			<div class="eh-row-4">
				<xsl:call-template name="Dept">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Inst']/child::*[local-name()='HCPerson']">
			<div class="eh-row-4">
				<xsl:call-template name="HCPerson">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='HCProf']">
			<div class="eh-row-4">
				<xsl:call-template name="HCProf">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Address']">
			<xsl:variable name="antall-tel" select="count(child::*[local-name()='TeleAddress'])"/>
			<div class="eh-row-4">
				<xsl:for-each select="child::*[local-name()='TeleAddress']">
					<xsl:call-template name="eh-TeleAddress"/>
				</xsl:for-each>
				<xsl:if test="child::*[local-name()='Type'] and (child::*[local-name()='PostalCode'] or child::*[local-name()='City'])">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">
							<xsl:call-template name="AddressKey"/>
						</div>
						<div class="eh-field">
							<xsl:call-template name="AddressValue"/>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
		<!-- Henvisende instans sin helsetjenesteenhetsid (PartyIdByRequester) og Tjenesteyters id av helsetjenesteenhet (PartyIdByServProv) er valgt utelatt -->
	</xsl:template>


	<!-- Visning av Person i helsevesenet -->
	<xsl:template name="HCProf">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='Type'] or child::*[local-name()='Name']">
			<div class="eh-col-2">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='Type']">
							<xsl:for-each select="child::*[local-name()='Type']">
								<xsl:call-template name="k-9060"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Helsepersonell</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="eh-field">
					<xsl:value-of select="child::*[local-name()='Name']"/>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Id'] or child::*[local-name()='AdditionalId']">
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='TypeId']">
							<xsl:for-each select="child::*[local-name()='TypeId']">
								<xsl:call-template name="k-8116"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Id</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="eh-field">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='AdditionalId']">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='AdditionalId']">
				<xsl:variable name="antall-id" select="count(child::*[local-name()='AdditionalId'])"/>
				<xsl:for-each select="child::*[local-name()='AdditionalId']">
					<xsl:call-template name="AdditionalId">
						<xsl:with-param name="col">
							<xsl:choose>
								<xsl:when test="position() = $antall-id">
									<xsl:value-of select="($col)-3-($antall-id)*2"/>
								</xsl:when>
								<xsl:otherwise>1</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:template>


	<!-- Visning av Institusjon -->
	<xsl:template name="Inst">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='Name']">
			<div class="eh-col-2">
				<div class="eh-label">Navn</div>
				<div class="eh-field">
					<xsl:value-of select="child::*[local-name()='Name']"/>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Id'] or child::*[local-name()='AdditionalId']">
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='TypeId']">
							<xsl:for-each select="child::*[local-name()='TypeId']">
								<xsl:call-template name="k-9051"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Id</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="eh-field">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='AdditionalId']">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='AdditionalId']">
				<xsl:variable name="antall-id" select="count(child::*[local-name()='AdditionalId'])"/>
				<xsl:for-each select="child::*[local-name()='AdditionalId']">
					<xsl:call-template name="AdditionalId">
						<xsl:with-param name="col">
							<xsl:choose>
								<xsl:when test="position() = $antall-id">
									<xsl:value-of select="($col)-3-($antall-id)*2"/>
								</xsl:when>
								<xsl:otherwise>1</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
		<!-- Type (Type) er valgt utelatt -->
	</xsl:template>


	<!-- Visning av Avdeling -->
	<xsl:template name="Dept">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='Type'] or child::*[local-name()='Name']">
			<div class="eh-col-2">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='Type']">
							<xsl:for-each select="child::*[local-name()='Type']">
								<xsl:call-template name="k-8624"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Avdeling</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="eh-field">
					<xsl:value-of select="child::*[local-name()='Name']"/>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Id'] or child::*[local-name()='AdditionalId']">
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='TypeId']">
							<xsl:for-each select="child::*[local-name()='TypeId']">
								<xsl:call-template name="k-9051"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Id</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="eh-field">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='AdditionalId']">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='AdditionalId']">
				<xsl:variable name="antall-id" select="count(child::*[local-name()='AdditionalId'])"/>
				<xsl:for-each select="child::*[local-name()='AdditionalId']">
					<xsl:call-template name="AdditionalId">
						<xsl:with-param name="col">
							<xsl:choose>
								<xsl:when test="position() = $antall-id">
									<xsl:value-of select="($col)-3-($antall-id)*2"/>
								</xsl:when>
								<xsl:otherwise>1</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:template>


	<!-- Visning av Person i organisasjon -->
	<xsl:template name="HCPerson">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='Name']">
			<div class="eh-col-2">
				<div class="eh-label">Helsepersonell</div>
				<div class="eh-field">
					<xsl:value-of select="child::*[local-name()='Name']"/>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Id'] or child::*[local-name()='AdditionalId']">
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='TypeId']">
							<xsl:for-each select="child::*[local-name()='TypeId']">
								<xsl:call-template name="k-8116"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Id</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="eh-field">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='AdditionalId']">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='AdditionalId']">
				<xsl:variable name="antall-id" select="count(child::*[local-name()='AdditionalId'])"/>
				<xsl:for-each select="child::*[local-name()='AdditionalId']">
					<xsl:call-template name="AdditionalId">
						<xsl:with-param name="col">
							<xsl:choose>
								<xsl:when test="position() = $antall-id">
									<xsl:value-of select="($col)-3-($antall-id)*2"/>
								</xsl:when>
								<xsl:otherwise>1</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:template>


	<!-- Visning av Alternativ id -->
	<xsl:template name="AdditionalId">
		<xsl:param name="col"/>
		<div class="eh-col-1">
			<div class="eh-label">
				<xsl:for-each select="child::*[local-name()='Type']">
					<xsl:choose>
						<xsl:when test="local-name(../..)='Patient' or local-name(../..)='HCProf' or local-name(../..)='HCPerson'">
							<xsl:call-template name="k-8116"/>
						</xsl:when>
						<xsl:when test="local-name(..)='Inst' or local-name(..)='Dept'">
							<xsl:call-template name="k-9051"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="k-dummy"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</div>
			<div class="eh-field">
				<xsl:value-of select="child::*[local-name()='Id']"/>
			</div>
		</div>
	</xsl:template>


	<!-- Visning av Adresse -->
	<xsl:template name="AddressKey">
		<xsl:choose>
			<xsl:when test="child::*[local-name()='Type']">
				<xsl:for-each select="child::*[local-name()='Type']">
					<xsl:call-template name="k-3401"/>
				</xsl:for-each>:
			</xsl:when>
			<xsl:otherwise>Adresse:</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="AddressValue">
		<xsl:if test="child::*[local-name()='StreetAdr']">
			<xsl:value-of select="child::*[local-name()='StreetAdr']"/>,&#32;</xsl:if>
		<xsl:if test="child::*[local-name()='PostalCode']">
			<xsl:value-of select="child::*[local-name()='PostalCode']"/>
		</xsl:if>
		<xsl:if test="child::*[local-name()='City']">&#8201;<xsl:value-of select="child::*[local-name()='City']"/>
		</xsl:if>
		<xsl:if test="child::*[local-name()='CityDistr']">,&#32;<xsl:for-each select="child::*[local-name()='CityDistr']"><xsl:call-template name="k-3403"/></xsl:for-each>
		</xsl:if>
		<xsl:if test="child::*[local-name()='County']">,&#32;<xsl:for-each select="child::*[local-name()='County']"><xsl:call-template name="k-3402"/></xsl:for-each>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Country']">,&#32;<xsl:for-each select="child::*[local-name()='Country']"><xsl:call-template name="k-9043"/></xsl:for-each>
		</xsl:if>
	</xsl:template>


	<!-- Visning av Telekommunikasjon -->
	<!-- Deprecated: se felleskomponenter/eh-komponent1.xsl : eh-TeleAddress -->
	<xsl:template name="TeleAddress">
		<xsl:param name="col"/>
		<div class="eh-col-1 eh-label">
			<xsl:choose>
				<xsl:when test="starts-with(@V, 'tel:') or starts-with(@V, 'callto:')">Telefon</xsl:when>
				<xsl:when test="starts-with(@V, 'fax:')">Faks</xsl:when>
				<xsl:when test="starts-with(@V, 'mailto:')">e-post</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-before(@V, ':')"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
		<div class="eh-col-2">
			<xsl:value-of select="substring-after(@V, ':')"/>
		</div>
	</xsl:template>


	<!-- Visning av vedlegg -->
	<!-- Deprecated: se felleskomponenter/eh-komponent1.xsl : eh-RefDoc -->
	<xsl:template name="RefDoc">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='MsgType'] or child::*[local-name()='Id'] or child::*[local-name()='IssueDate'] or child::*[local-name()='MimeType'] or child::*[local-name()='Compression']">
			<div class="eh-row">
				<xsl:if test="child::*[local-name()='MsgType']">
					<div class="eh-col-1 eh-label">Type</div>
					<div class="eh-col-1">
						<xsl:for-each select="child::*[local-name()='MsgType']">
							<xsl:call-template name="k-8114"/>
						</xsl:for-each>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Id']">
					<div class="eh-col-1 eh-label">Id</div>
					<div class="eh-col-1">
						<xsl:value-of select="child::*[local-name()='Id']"/>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='IssueDate']">
					<div class="eh-col-1 eh-label">Utstedt-dato</div>
					<div class="eh-col-1">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']/@V"/>
							<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
						</xsl:call-template>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='MimeType']">
					<div class="eh-col-1 eh-label">Mimetype</div>
					<div class="eh-col-1 eh-last-child">
						<xsl:value-of select="child::*[local-name()='MimeType']"/>
					</div>
				</xsl:if>
			</div>
			<xsl:if test="child::*[local-name()='Compression']">
				<div class="eh-row">
					<div class="eh-col-1 eh-label">Komprimering</div>
					<div class="eh-col-1 eh-last-child">
						<xsl:for-each select="child::*[local-name()='Compression']">
							<xsl:call-template name="k-1204"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Description']">
			<div class="eh-row">
				<div class="eh-col-1 eh-label">Beskrivelse</div>
				<div class="eh-col-1 eh-last-child">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="child::*[local-name()='Description']"/>
					</xsl:call-template>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Content'] or child::*[local-name()='FileReference']">
			<xsl:choose>
				<xsl:when test="contains(child::*[local-name()='MimeType'],'image')">
					<div class="eh-row">
						<div class="eh-col-1 eh-label">Bilde</div>
						<xsl:choose>
							<xsl:when test="child::*[local-name()='FileReference']">
								<div class="eh-col-1 eh-last-child">
									<img style="max-width: 100%;">
										<xsl:attribute name="src"><xsl:value-of select="child::*[local-name()='FileReference']"/></xsl:attribute>
										<xsl:attribute name="alt">Bilde fra ekstern URL</xsl:attribute>
									</img>
								</div>
							</xsl:when>
							<xsl:when test="child::*[local-name()='Content']">
								<div class="eh-col-1 eh-last-child">
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
								</div>
							</xsl:when>
						</xsl:choose>
					</div>
				</xsl:when>
				<xsl:when test="contains(child::*[local-name()='MimeType'],'pdf') or contains(child::*[local-name()='MimeType'],'PDF')">
					<div class="eh-row">
						<div class="eh-col-1 eh-label">pdf</div>
						<div class="eh-col-1 eh-last-child">Hvis du ikke ser pdf-vedlegget kan du prøve en annen nettleser.</div>
					</div>
					<div class="eh-row">
						<div class="eh-col-1">&#160;</div>
						<xsl:choose>
							<xsl:when test="child::*[local-name()='FileReference']">
								<div class="eh-col-7 eh-last-child">
									<table>
									<tbody>
									<tr><td>
										<object>
											<xsl:attribute name="data"><xsl:value-of select="concat(child::*[local-name()='FileReference'],'&#35;view&#61;FitH&#38;toolbar&#61;1')"/></xsl:attribute>
											<xsl:attribute name="type">application/pdf</xsl:attribute>
											<xsl:attribute name="width">100%</xsl:attribute>
											<xsl:attribute name="height">500px</xsl:attribute>
										</object>
									</td></tr>
									</tbody>
									</table>
								</div>
							</xsl:when>
							<xsl:when test="child::*[local-name()='Content']">
								<div class="eh-col-7 eh-last-child">
									<xsl:choose>
										<xsl:when test="child::*[local-name()='Content']/base:Base64Container">
											<table>
											<tbody>
											<tr><td>
												<object>
													<xsl:attribute name="data"><xsl:value-of select="concat('data:application/pdf;base64,',child::*[local-name()='Content']/base:Base64Container)"/></xsl:attribute>
													<xsl:attribute name="type">application/pdf</xsl:attribute>
													<xsl:attribute name="width">100%</xsl:attribute>
													<xsl:attribute name="height">500px</xsl:attribute>
												</object>
											</td></tr>
											</tbody>
											</table>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="child::*[local-name()='Content']"/>
										</xsl:otherwise>
									</xsl:choose>
								</div>
							</xsl:when>
						</xsl:choose>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="eh-row">
						<div class="eh-col-8 eh-last-child">
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
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
