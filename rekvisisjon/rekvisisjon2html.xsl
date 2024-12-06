<?xml version="1.0" encoding="utf-8"?>
<!--

Endringslogg
- 07.03.23: v5.3.1 - Byttet avsender og mottaker i Header
- 09.08.22: v5.3.0 - Semantisk HTML
- 25.05.22: v5.2.0 - Oppdatert Footer (Dokumentinformasjon)
- 16.05.22: v5.1.2 - Legg til fødselsdag og kjønn i Header hvis fødselsnummer ikke finnes + kopimottakere i Header på egen linje
- 11.10.21: v5.1.1 - Definer Anonymisert, legg til manglende xsl:choose
- 03.09.21: v5.1.0 - Endre oppsett Header
- 04.06.21: v5.0.3 - Lagt til xsl:output for å definere at output formatet skal være html
- 31.05.21: v5.0.2 - Tillate MimeType (vedlegg) med store bokstaver
- 27.04.21: v5.0.1 - Oppdater regler for visning av Pasient-informasjon
- 08.04.21: v5.0.0 - Endre <span> til <div>, siden block-elementer (<ul>) inni inline-elementer (<span>) kan gi feil visning.
- 26.06.17: v4.1.4 - La til <br/> i forbindelse med opplisting av kopi-mottakere, slik at de ikke havner på samme linje,
- 20.06.17: v4.1.3 - Endret fra "Tjenesteyter" til "Mottaker" og fra "Henvisende instans" til "Avsender"
						    Korrigert slik at Rekvirent vises under helsetjenesteenheter. Feil i koden som gjorde at den ikke ble vist.
							Endret fra "eh-row-4" til "eh-row-5" i forbindelse med visning av adresseinformasjon for pasient. Dette for å få overskrifter til å passe med linjen over.
							Erstattet hairspace med puncspace som mellomromstegn. Benyttet &#8200;
- 17.03.17: v4.1.2 - Ny stil "Smooth".
- 09.02.17: v4.1.1 - Ny global parameter for "visningStil" fra kommando-linjen. Html/Css responsive.
- 01.02.17: v4.1.0 - Slått sammen ledetekst og verdi fra 2 til 1 kolonne for bedre responsive.
- 01.02.17: v4.0.2 - Liten layout fix i Vedlegg m.m.
- 13.01.16: v4.0.1 - Fix av CSS vedr. lang tekst i siste kolonne.
- 09.11.16: v4.0.0 - Opprettet felles visning for alle versjonene av rekvisisjon. (v1.4, v1.5, v1.6)
- 25.10.16: v3.1.0 - La til visningsversjonnr
- 09.05.14: La til import av kodeverk-fil
- 27.04.11: La til visning av flere enn en underavdeling ved pasientopphold, la til visning av Comment/TextResultValue, samt erstattet mange <br/> med <div>.
- 01.12.10: Import av felles CSS-fil
- 10.07.09: Felles komplett visningsfil for rekvisisjon
- 04.02.09: Oppdatert adresse for namespace for v1.5
- 06.05.08: Andre versjon etter forslag sendt inn 28.04

Design:
- Responsive kollaps ved 767px bredde.
- Ingen tomme felt så langt det lar seg gjøre
- Klikkbar menylinje
- Headervisning avhengig av utskriftsmedium
- Kommentarer for ofte tildelt fulle rader
Svakheter:
- Fravær av obligatoriske element kan gi tomme bokser/rader
- Fravær av DN-attributt (ev. OT-attributt) kan gi {Ukjent kode} i visningen
Om:
- Inngår i Direktoratet for e-helse visningsfiler

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:base="http://www.kith.no/xmlstds/base64container"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:doc14="http://www.kith.no/xmlstds/rekvisisjon/2005-05-20"
	xmlns:doc15="http://www.kith.no/xmlstds/rekvisisjon/2008-12-01"
	xmlns:doc16="http://www.kith.no/xmlstds/rekvisisjon/2012-02-15"
	exclude-result-prefixes="xhtml base">

	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../felleskomponenter/eh-komponent1.xsl"/>
	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Variabler for antall kolonner -->
	<xsl:variable name="std-col" select="10"/>

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'rekvisisjon v.uavhengig - v5.3.1'"/>

	<xsl:variable name="VisOvrigHelsetjenesteInfoVisSkjul" select="true()"/>
	<xsl:variable name="VisDokInfoVisSkjul" select="true()"/>
    <xsl:variable name="Anonymisert" select="false()"/>

    <xsl:variable name="IsTestMessage" select="
		boolean(/doc14:Message/doc14:Status[@V = 'TEST'])
		or boolean(/doc15:Message/doc15:Status[@V = 'TEST'])
		or boolean(/doc16:Message/doc16:Status[@V = 'TEST'])" />

	<xsl:param name="VisMenylinje"/>

	<xsl:variable name="menylinje">
		<xsl:choose>
			<xsl:when test="$VisMenylinje = 'false'">
				<xsl:value-of select="false()"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="true()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- Meldingsstart -->
	<xsl:template match="/">
		<html>
			<head>
				<title>Rekvisisjon</title>
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
				<xsl:for-each select="child::*[local-name()='Message']">
					<xsl:call-template name="Message"/>
				</xsl:for-each>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="Message">
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
										<xsl:otherwise>Lenestol,&#160;Rød&#160;</xsl:otherwise>
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
										<xsl:otherwise>19667801365</xsl:otherwise>
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
										<xsl:otherwise>19.01.78</xsl:otherwise>
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
					</xsl:when>
					<xsl:when test="child::*[local-name()='Animal']">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Undersøkelsesdyr&#160;</div>
							<div class="No-line-content">
								<xsl:for-each select="child::*[local-name()='Animal']">
									<xsl:call-template name="AnimalHode"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:when>
					<xsl:when test="child::*[local-name()='Material']">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Materiale&#160;</div>
							<div class="No-line-content">
								<xsl:for-each select="child::*[local-name()='Material']">
									<xsl:call-template name="MaterialHode"/>
								</xsl:for-each>
							</div>
						</div>
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

	<xsl:template name="AnimalHode">
		<div>
			<xsl:if test="child::*[local-name()='Name']"><b>Navn</b>:&#160;<xsl:value-of select="child::*[local-name()='Name']"/>&#160;</xsl:if>
			<xsl:if test="child::*[local-name()='Species']"><b>Art</b>:&#160;<xsl:value-of select="child::*[local-name()='Species']"/>&#160;</xsl:if>
			<xsl:if test="child::*[local-name()='NameOwner']"><b>Eier</b>:&#160;<xsl:value-of select="child::*[local-name()='NameOwner']"/>&#160;</xsl:if>
		</div>
	</xsl:template>

	<xsl:template name="MaterialHode">
		<div>
			<xsl:if test="child::*[local-name()='InvMaterial']"><b>Beskrivelse</b>:&#160;<xsl:value-of select="child::*[local-name()='InvMaterial']"/>&#160;</xsl:if>
		</div>
	</xsl:template>

	<xsl:template name="HCPersonHode">
		<div>
			<xsl:value-of select="child::*[local-name()='Name']"/>
			<div class="NoPrint">,</div>&#160;</div>
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
			<xsl:value-of select="child::*[local-name()='Name']"/>
		</div>
		<xsl:for-each select="child::*[local-name()='Dept']">
			<div>
				<div class="NoPrint">-&#160;</div>
				<xsl:value-of select="child::*[local-name()='Name']"/>&#160;</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="HCProfHode">
		<div>
			<xsl:for-each select="child::*[local-name()='Type']">
				<xsl:call-template name="k-9060"/>
			</xsl:for-each>&#160;<xsl:value-of select="child::*[local-name()='Name']"/>
		</div>
	</xsl:template>

	<xsl:template name="CopyDestHode">
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCPHode"/>
		</xsl:for-each>
	</xsl:template>


	<!-- Hoveddokument -->
	<xsl:template name="ResultBody"> <!-- /Message/ServReq -->
		<main class="{$stil}">
			<xsl:variable name="position" select="position()"/>
			<!-- Tabell for rekvisisjon -->
			<h1>Rekvisisjon
				<xsl:for-each select="child::*[local-name()='MsgDescr']">
					<xsl:call-template name="k-8202"/>
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='ServType']">&#160;-
					<xsl:call-template name="k-7309"/>
				</xsl:for-each>
			</h1>
			<xsl:if test="$menylinje = 'true'">
				<xsl:call-template name="FellesMeny">
					<xsl:with-param name="position" select="position()"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:variable name="id1">
				<xsl:value-of select="concat('ServReq',$position)"/>
			</xsl:variable>

			<section>
				<h2 id="{$id1}">Meldingsinformasjon</h2>
				<div class="eh-section">
					<xsl:call-template name="ServReq"/>
				</div>
			</section>

			<!-- Tabell for rekvirert undersøkelse -->
			<xsl:for-each select=".//child::*[local-name()='ReqInvestigation']"> <!-- maxOccurs="unbounded" -->
				<xsl:variable name="id2">
					<xsl:value-of select="concat('ReqInvestigation',$position,position())"/>
				</xsl:variable>

				<section>
					<h2 id="{$id2}">
						<xsl:choose>
							<xsl:when test="last()!=1">
								<xsl:value-of select="concat('Rekvirert undersøkelse ',position())"/>
							</xsl:when>
							<xsl:otherwise>Rekvirert undersøkelse</xsl:otherwise>
						</xsl:choose>
						<xsl:for-each select="child::*[local-name()='ServType']">&#160;-
							<xsl:call-template name="k-7309"/>
						</xsl:for-each>
					</h2>
					<div class="eh-section">
						<xsl:call-template name="ReqInvestigation"/>
					</div>
				</section>
			</xsl:for-each>

			<!-- Tabell for øvrig pasientinformasjon -->
			<xsl:for-each select="child::*[local-name()='Patient']">
				<xsl:if test="child::*[local-name()='OffId'] and child::*[local-name()='TypeOffId']">
					<xsl:variable name="id5">
						<xsl:value-of select="concat('Patient',$position)"/>
					</xsl:variable>

					<section>
						<h2 id="{$id5}">Pasient</h2>

						<div class="eh-section">
							<xsl:call-template name="Patient">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:call-template>
						</div>
					</section>
				</xsl:if>
			</xsl:for-each>

			<!-- Tabell for øvrig informasjon om undersøkelsesobjekt: dyr -->
			<xsl:for-each select="child::*[local-name()='Animal']">
				<xsl:if test="child::*[local-name()='Sex'] or child::*[local-name()='Animal']">
					<xsl:variable name="id6">
						<xsl:value-of select="concat('Animal',$position)"/>
					</xsl:variable>

					<section>
						<h2 id="{$id6}">Undersøkelsesdyr</h2>
						<div class="eh-section">
							<xsl:call-template name="Animal">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:call-template>
						</div>
					</section>
				</xsl:if>
			</xsl:for-each>

			<!-- Tabell for alle tilknyttede helsetjenesteenheter -->
			<xsl:variable name="id7">
				<xsl:value-of select="concat('HCP',$position)"/>
			</xsl:variable>

			<section>
				<h2 id="{$id7}">Helsetjenesteenheter</h2>

				<xsl:if test="$VisOvrigHelsetjenesteInfoVisSkjul">
					<label for="vis{$id7}" class="VisSkjul">Vis/Skjul</label>
					<input type="checkbox" checked="true" id="vis{$id7}" style="display: none;"/>
				</xsl:if>

				<div class="eh-section xs">
					<xsl:for-each select="child::*[local-name()='ServProvider']">
						<xsl:call-template name="ServProvider" >
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:call-template>
					</xsl:for-each>
					<xsl:if test="child::*[local-name()='ServProvider']">
						<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#8200;</div></div> <!-- separator line when collapsed -->
					</xsl:if>

					<xsl:for-each select="child::*[local-name()='Requester']">
						<xsl:call-template name="Requester" >
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:call-template>
					</xsl:for-each>
					<xsl:if test="child::*[local-name()='Requester']">
						<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#8200;</div></div> <!-- separator line when collapsed -->
					</xsl:if>

					<xsl:for-each select="child::*[local-name()='PaymentResponsible']">
						<xsl:call-template name="PaymentResponsible" >
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:call-template>
					</xsl:for-each>
					<xsl:if test="child::*[local-name()='PaymentResponsible']">
						<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#8200;</div></div> <!-- separator line when collapsed -->
					</xsl:if>

					<xsl:for-each select="child::*[local-name()='CopyDest']">
						<xsl:call-template name="CopyDest" >
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:call-template>
					</xsl:for-each>
					<xsl:if test="child::*[local-name()='CopyDest']">
						<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#8200;</div></div> <!-- separator line when collapsed -->
					</xsl:if>

					<xsl:for-each select="child::*[local-name()='Patient']/child::*[local-name()='ResponsibleHcp']">
						<xsl:call-template name="ResponsibleHcp" >
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:call-template>
					</xsl:for-each>
					<xsl:if test="child::*[local-name()='ResponsibleHcp']">
						<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#8200;</div></div> <!-- separator line when collapsed -->
					</xsl:if>

					<!--<xsl:for-each select="child::*[local-name()='Patient']">
						<xsl:call-template name="Patient" >
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:call-template>
					</xsl:for-each>-->

					<xsl:for-each select="child::*[local-name()='AdmLocation']">
						<xsl:call-template name="AdmLocation" >
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:call-template>
					</xsl:for-each>
					<xsl:if test="child::*[local-name()='AdmLocation']">
						<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#8200;</div></div> <!-- separator line when collapsed -->
					</xsl:if>
				</div>
			</section>

			<!-- Tabell for vedlegg -->
			<xsl:if test="child::*[local-name()='RefDoc']">
				<xsl:variable name="id8">
					<xsl:value-of select="concat('RefDoc',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id8}">Vedlegg</h2>
					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='RefDoc']">
							<xsl:call-template name="RefDoc">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:call-template>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>
		</main>
	</xsl:template>

	<!-- Meldingshodet - dokumentopplysninger -->
	<xsl:template name="Footer">

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
					<xsl:if test="child::*[local-name()='ServType']">
						<div class="eh-col-1">
							<div class="eh-label">Meldingsstatus</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='ServType']">
									<xsl:call-template name="k-7309"/>
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

	<!-- Klikkbar horisontal meny som leder lenger ned i dokumentet -->
	<xsl:template name="FellesMeny">
		<xsl:param name="position"/>
		<nav id="FellesMeny" class="FellesMeny NoPrint">
			<ul>
				<li>
					<xsl:variable name="temp1" select="concat('ServReq',$position)"/>
					<a href="#{$temp1}">Meldingsinformasjon</a>
				</li>
				<xsl:for-each select=".//child::*[local-name()='ReqInvestigation']">
					<li>
						<xsl:variable name="temp2" select="concat('ReqInvestigation',$position,position())"/>
						<xsl:choose>
							<xsl:when test="last()!=1">
								<a href="#{$temp2}">
									<xsl:value-of select="concat('Rekvirert undersøkelse',position())"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a href="#{$temp2}">Rekvirert undersøkelse</a>
							</xsl:otherwise>
						</xsl:choose>
					</li>
				</xsl:for-each>
				<xsl:if test=".//child::*[local-name()='Patient']/child::*[local-name()='OffId'] and .//child::*[local-name()='Patient']/child::*[local-name()='TypeOffId']">
					<li>
						<xsl:variable name="temp3" select="concat('Patient',$position)"/>
						<a href="#{$temp3}">Pasient</a>
					</li>
				</xsl:if>
				<xsl:if test=".//child::*[local-name()='Animal']/child::*[local-name()='Sex'] or .//child::*[local-name()='Animal']/child::*[local-name()='Animal']">
					<li>
						<xsl:variable name="temp4" select="concat('Animal',$position)"/>
						<a href="#{$temp4}">Undersøkelsesdyr</a>
					</li>
				</xsl:if>
				<xsl:if test=".//child::*[local-name()='ServProvider'] | .//child::*[local-name()='Requester'] | .//child::*[local-name()='PaymentResponsible'] | .//child::*[local-name()='CopyDest'] | .//child::*[local-name()='ResponsibleHcp'] | .//child::*[local-name()='Patient']/child::*[local-name()='AdmLocation']">
					<li>
						<xsl:variable name="temp5" select="concat('HCP',$position)"/>
						<a href="#{$temp5}">Helsetjenesteenheter</a>
					</li>
				</xsl:if>
				<xsl:if test=".//child::*[local-name()='RefDoc']">
					<li>
						<xsl:variable name="temp6" select="concat('RefDoc',$position)"/>
						<a href="#{$temp6}">Vedlegg</a>
					</li>
				</xsl:if>
			</ul>
		</nav>
	</xsl:template>

	<xsl:template name="ServReq"> <!-- /Message/ServReq -->
		<xsl:if test="child::*[local-name()='IssueDate'] or child::*[local-name()='RequestedDateReport'] or child::*[local-name()='RequestedPrioReport'] or child::*[local-name()='PaymentCat']">
			<div class="eh-row-4">
				<xsl:if test="child::*[local-name()='IssueDate']">
					<div class="eh-col-1">
						<div class="eh-label">Utstedt dato</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='RequestedDateReport']">
					<div class="eh-col-1">
						<div class="eh-label">Ønsket svartid</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='RequestedDateReport']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='RequestedPrioReport']">
					<div class="eh-col-1">
						<div class="eh-label">Ønsket prioritet</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='RequestedPrioReport']">
								<xsl:choose>
									<xsl:when test="namespace-uri() = 'http://www.kith.no/xmlstds/rekvisisjon/2012-02-15'">
										<xsl:call-template name="k-8115"/> <!-- v1.6 -->
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="k-7303"/> <!-- v1.5 and below -->
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='PaymentCat']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Betalings&#173;kategori</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='PaymentCat']">
								<xsl:call-template name="k-4101"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
			<xsl:if test="child::*[local-name()='Reservation']"> <!-- maxOccurs="unbounded" -->
				<div class="eh-row-4 blk-cmt">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Pasientens reservasjoner</div>
						<div class="eh-field blk">
							<xsl:for-each select="child::*[local-name()='Reservation']">
								<xsl:if test="position() &gt; 1">
									<br/>
								</xsl:if>
								<xsl:call-template name="k-3108"/>
							</xsl:for-each>
						</div>
					</div>
				</div>
			</xsl:if>

		</xsl:if>
		<xsl:if test="child::*[local-name()='NoReport'] or child::*[local-name()='LevelOfDetail'] or child::*[local-name()='EscortRequired'] or child::*[local-name()='Permission']">
			<div class="eh-row-4">
				<xsl:if test="child::*[local-name()='NoReport']">
					<div class="eh-col-1">
						<div class="eh-label">Ønsker svar</div>
						<div class="eh-field">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='NoReport']/@V='false'">Ja</xsl:when>
								<xsl:otherwise>Nei</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='LevelOfDetail']">
					<div class="eh-col-1">
						<div class="eh-label">Ønsket detaljnivå</div>
						<div class="eh-field">
							<xsl:apply-templates select="child::*[local-name()='LevelOfDetail']"/>  <!-- string -->
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='EscortRequired']">
					<div class="eh-col-1">
						<div class="eh-label">Ledsagelses&#173;behov</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='EscortRequired']">
								<xsl:call-template name="k-8247"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Permission']">
					<div class="eh-col-1">
						<div class="eh-label">Tillatelser</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Permission']">
								<xsl:call-template name="k-dummy"/>
								<xsl:if test="position()!=last()">.&#160;&#160;</xsl:if>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='ReqComment']"> <!-- maxOccurs="1" -->
			<div class="eh-row-4 blk-cmt">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Rekvirentens kommentar</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='ReqComment']"/>
						</xsl:call-template>
					</div>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='ReasonAsText']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-label h3 eh-last-child">Begrunnelser</div>
			</div>
			<xsl:for-each select="child::*[local-name()='ReasonAsText']"> <!-- maxOccurs="unbounded" -->
				<xsl:call-template name="ReasonAsText"/>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Comment']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-label h3 eh-last-child">Kommentarer</div>
			</div>
			<xsl:for-each select="child::*[local-name()='Comment']"> <!-- maxOccurs="unbounded" -->
				<xsl:call-template name="Comment"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template name="ReqInvestigation">
		<xsl:if test="child::*[local-name()='Purpose'] or child::*[local-name()='ReqDate'] or child::*[local-name()='Priority']">
			<div class="eh-row-4">
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
						<div class="eh-label">Ønsket tidspunkt</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='ReqDate']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Priority']">
					<div class="eh-col-1">
						<div class="eh-label">Hastegrad</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Priority']">
								<xsl:call-template name="k-8304"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Comment']"> <!-- maxOccurs="1" -->
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
		<xsl:if test="child::*[local-name()='Investigation']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-label h3 eh-last-child">Undersøkelse</div>
			</div>
			<xsl:for-each select="child::*[local-name()='Investigation']">
				<xsl:if test="child::*[local-name()='Id'] or child::*[local-name()='Spec'] or child::*[local-name()='Comment'] or child::*[local-name()='Priority']">
					<div class="eh-row-4">
						<xsl:if test="child::*[local-name()='Id']">
							<div class="eh-col-1">
								<div class="eh-label">Type</div>
								<div class="eh-field">
									<xsl:for-each select="child::*[local-name()='Id']">
										<xsl:choose>
											<xsl:when test="contains(@S, '8219')">
												<xsl:call-template name="k-8219"/>
											</xsl:when>
											<xsl:when test="contains(@S, '8220')">
												<xsl:call-template name="k-8220"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="k-dummy"/>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:if test="position()!=last()">,&#160;</xsl:if>
									</xsl:for-each>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='Spec']">
							<div class="eh-col-1">
								<div class="eh-label">Spesifisert</div>
								<div class="eh-field">
									<xsl:for-each select="child::*[local-name()='Spec']">
										<xsl:call-template name="k-dummy"/>
										<xsl:if test="position()!=last()">,&#160;</xsl:if>
									</xsl:for-each>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='Comment']">
							<div class="eh-col-1">
								<div class="eh-label">Kommentar</div>
								<div class="eh-field">
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="child::*[local-name()='Comment']"/>
									</xsl:call-template>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='Priority']">
							<div class="eh-col-1">
								<div class="eh-label">Hastegrad</div>
								<div class="eh-field">
									<xsl:for-each select="child::*[local-name()='Priority']">
										<xsl:call-template name="k-8304"/>
									</xsl:for-each>
								</div>
							</div>
						</xsl:if>
					</div>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="child::*[local-name()='StandingInv']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-label h3 eh-last-child">Gjentagende undersøkelse</div>
			</div>
			<xsl:for-each select="child::*[local-name()='StandingInv']">
				<xsl:if test="child::*[local-name()='NumberOfTimes'] or child::*[local-name()='ScheduledStart'] or child::*[local-name()='ScheduledEnd'] or child::*[local-name()='CycleTime']">
					<div class="eh-row-4">
						<xsl:if test="child::*[local-name()='NumberOfTimes']">
							<div class="eh-col-1">
								<div class="eh-label">Antall repetisjoner</div>
								<div class="eh-field">
									<xsl:value-of select="child::*[local-name()='NumberOfTimes']"/>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='ScheduledStart']">
							<div class="eh-col-1">
								<div class="eh-label">Planlagt start</div>
								<div class="eh-field">
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='ScheduledStart']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='ScheduledEnd']">
							<div class="eh-col-1">
								<div class="eh-label">Planlagt slutt</div>
								<div class="eh-field">
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='ScheduledEnd']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='CycleTime']">
							<div class="eh-col-1">
								<div class="eh-label">Intervall</div>
								<div class="eh-field">
									<xsl:value-of select="child::*[local-name()='CycleTime']"/>
								</div>
							</div>
						</xsl:if>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='EndCondition']"> <!-- maxOccurs="1" -->
					<div class="eh-row-4">
						<div class="eh-col-1 eh-last-child">
							<div class="eh-label">Sluttbetingelser</div>
							<div class="eh-field">
								<xsl:value-of select="child::*[local-name()='EndCondition']"/>
							</div>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Instructions']"> <!-- maxOccurs="1" -->
					<div class="eh-row-4">
						<div class="eh-col-1 eh-last-child">
							<div class="eh-label">Instruksjon</div>
							<div class="eh-field">
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="child::*[local-name()='Instructions']"/>
								</xsl:call-template>
							</div>
						</div>
					</div>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="child::*[local-name()='AnalysedSubject']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-label h3 eh-last-child">Prøve</div>
			</div>
			<xsl:for-each select="child::*[local-name()='AnalysedSubject']">
				<xsl:call-template name="AnalysedSubject">
					<xsl:with-param name="col" select="$std-col"/>
					<xsl:with-param name="pos" select="position()"/>
					<xsl:with-param name="last" select="last()"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Comment">
		<xsl:if test="child::*[local-name()='Heading'] or child::*[local-name()='TextResultValue'] or child::*[local-name()='TextCode']">
			<div class="eh-row-4 blk-cmt">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='Heading']">
								<xsl:for-each select="child::*[local-name()='Heading']">
									<xsl:call-template name="k-8234"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:when test="contains(child::*[local-name()='TextCode']/@S,'8274')">Anbefaling om supplerende undersøkelse</xsl:when>
							<xsl:otherwise>Generell</xsl:otherwise>
						</xsl:choose>
					</div>
					<div class="eh-field">
						<xsl:if test="child::*[local-name()='TextResultValue']">
							<xsl:value-of select="child::*[local-name()='TextResultValue']"/>
						</xsl:if>
						<xsl:for-each select="child::*[local-name()='TextCode']">
							<xsl:choose>
								<xsl:when test="contains(@S,'8274')">
									<xsl:call-template name="k-8274"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="k-dummy"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</div>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="ReasonAsText">
		<xsl:if test="child::*[local-name()='Heading'] or child::*[local-name()='TextResultValue']">
			<div class="eh-row-4 blk-cmt">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">
						<xsl:for-each select="child::*[local-name()='Heading']">
							<xsl:call-template name="k-8231"/>
						</xsl:for-each>
					</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='TextResultValue']">
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
					</div>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Patient">
		<xsl:param name="col"/>
		<div class="eh-row-5">
			<div class="eh-col-1">
				<div class="eh-label">Navn<xsl:if test="child::*[local-name()='Relation'] and local-name(..)='Patient'">&#160;-&#160;relasjon:&#160;<xsl:for-each select="child::*[local-name()='Relation']">
							<xsl:call-template name="k-8238"/>
						</xsl:for-each>
					</xsl:if>
				</div>
				<div class="eh-field">
					<xsl:value-of select="child::*[local-name()='Name']"/>
				</div>
			</div>
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:for-each select="child::*[local-name()='TypeOffId']">
						<xsl:call-template name="k-8116"/>
					</xsl:for-each>
				</div>
				<div class="eh-field">
					<xsl:value-of select="child::*[local-name()='OffId']"/>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='Sex']">
				<div class="eh-col-1">
					<div class="eh-label">Kjønn</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Sex']">
							<xsl:call-template name="k-3101"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='DateOfBirth']">
				<div class="eh-col-1">
					<div class="eh-label">Fødselsdato</div>
					<div class="eh-field">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateOfBirth']/@V"/>
							<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='DateOfDeath']">
				<div class="eh-col-1">
					<div class="eh-label">Dødsdato</div>
					<div class="eh-field">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateOfDeath']/@V"/>
							<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
		<xsl:for-each select="child::*[local-name()='Address']">
			<xsl:variable name="antall-tel" select="count(child::*[local-name()='TeleAddress'])"/>
			<div class="eh-row-5">
				<xsl:for-each select="child::*[local-name()='TeleAddress']">
					<xsl:call-template name="TeleAddress">
						<xsl:with-param name="col" select="(($col)-1)*number(not(child::*[local-name()='Type'] and (child::*[local-name()='PostalCode'] or child::*[local-name()='City'])))+1"/>
					</xsl:call-template>
				</xsl:for-each>
				<xsl:if test="child::*[local-name()='Type'] and (child::*[local-name()='PostalCode'] or child::*[local-name()='City'])">
					<xsl:call-template name="Address">
						<xsl:with-param name="col" select="($col)-1-($antall-tel)*2"/>
					</xsl:call-template>
				</xsl:if>
			</div>
		</xsl:for-each>
		<xsl:if test="child::*[local-name()='AdditionalId'] or child::*[local-name()='BasisForHealthServices']">
			<xsl:variable name="antall-id" select="count(child::*[local-name()='AdditionalId'])"/>
			<div class="eh-row-4">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='AdditionalId'] and child::*[local-name()='BasisForHealthServices']">
						<div class="eh-col-2">
							<div class="eh-label">Andre pasient-identifikatorer</div>
							<div class="eh-field blk">
								<xsl:for-each select="child::*[local-name()='AdditionalId']"> <!-- maxOccurs="unbounded" -->
									<xsl:if test="position() &gt; 1">
										<br/>
									</xsl:if>
									<xsl:call-template name="AdditionalId">
										<xsl:with-param name="col" select="false()"/>
									</xsl:call-template>
								</xsl:for-each>
							</div>
						</div>
						<div class="eh-col-1 eh-last-child">
							<div class="eh-label">Refusjons&#173;grunnlag</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='BasisForHealthServices']">
									<xsl:call-template name="k-8246"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:when>
					<xsl:when test="child::*[local-name()='AdditionalId'] and not(child::*[local-name()='BasisForHealthServices'])">
						<div class="eh-col-2 eh-last-child">
							<div class="eh-field blk">
								<div class="eh-label">Andre pasient-identifikatorer</div>
								<xsl:for-each select="child::*[local-name()='AdditionalId']">
									<xsl:if test="position() &gt; 1">
										<br/>
									</xsl:if>
									<xsl:call-template name="AdditionalId">
										<xsl:with-param name="col" select="false()"/>
									</xsl:call-template>
								</xsl:for-each>
							</div>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="eh-col-1 eh-last-child">
							<div class="eh-label">Refusjons&#173;grunnlag</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='BasisForHealthServices']">
									<xsl:call-template name="k-8246"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:if>
		<xsl:for-each select="child::*[local-name()='AdmLocation']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-label h3 eh-last-child">
					Opphold
				</div>
			</div>
			<div class="eh-row-4">
				<div class="eh-col-1">
					<div class="eh-label">Institusjon</div>
					<div class="eh-field">
						<!-- Gir her boksen en default kolonnebredde på 3 mot normalt 1 -->
						<xsl:value-of select="child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Name']"/>
						<xsl:if test="child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Dept']/child::*[local-name()='Name']">
							<xsl:for-each select="child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Dept']">, <xsl:value-of select="child::*[local-name()='Name']"/>
							</xsl:for-each>
						</xsl:if>
						<xsl:for-each select="child::*[local-name()='Location']/child::*[local-name()='SubLocation']">, <xsl:for-each select="child::*[local-name()='Type']">
								<xsl:call-template name="k-8242"/>
							</xsl:for-each>: <xsl:value-of select="child::*[local-name()='Place']"/>
						</xsl:for-each>
					</div>
				</div>
				<xsl:if test="child::*[local-name()='AdmCat']">
					<div class="eh-col-1">
						<div class="eh-label">Type tjeneste</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='AdmCat']">
								<xsl:call-template name="k-8240"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='StartDateTime']">
					<div class="eh-col-1">
						<div class="eh-label">Innlagt dato</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='EndDateTime']">
					<div class="eh-col-1">
						<div class="eh-label">Utskrevet dato</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
		<!-- Feil ?? Er allerede på Patient -->
		<!--<xsl:for-each select="child::*[local-name()='Patient']">
			<xsl:call-template name="Patient">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>-->
		<xsl:for-each select="child::*[local-name()='InfItem']">
			<xsl:call-template name="InfItem">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="Animal">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<xsl:if test="child::*[local-name()='NameOwner']">
				<div class="eh-col-1">
					<div class="eh-label">Eier&#160;</div>
					<div class="eh-field">
						<xsl:value-of select="child::*[local-name()='NameOwner']"/>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Name']">
				<div class="eh-col-1">
					<div class="eh-label">Navn&#160;
						<xsl:if test="local-name(..)='Animal'">
							-&#160;relasjon:&#160;<xsl:for-each select="child::*[local-name()='Relation']">
								<xsl:call-template name="k-8238"/>
							</xsl:for-each>
						</xsl:if>
					</div>
					<div class="eh-field">
						<xsl:value-of select="child::*[local-name()='Name']"/>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Sex']">
				<div class="eh-col-1">
					<div class="eh-label">Kjønn</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Sex']">
							<xsl:call-template name="k-3101"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Species']">
				<div class="eh-col-1">
					<div class="eh-label">Art</div>
					<div class="eh-field">
						<xsl:value-of select="child::*[local-name()='Species']"/>
					</div>
				</div>
			</xsl:if>
		</div>
		<xsl:for-each select="child::*[local-name()='Animal']"> <!-- Feil ?? Er allerede på Animal -->
			<xsl:call-template name="Animal">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="AnalysedSubject">
		<xsl:param name="col"/>
		<xsl:param name="pos"/>
		<xsl:param name="last"/>
		<xsl:if test="child::*[local-name()='Type'] or child::*[local-name()='TypeCoded'] or child::*[local-name()='IdByRequester'] or child::*[local-name()='RequestedSubject'] or child::*[local-name()='CollectedSample'] or child::*[local-name()='CollectedStudyProduct']">
			<div class="eh-row-4">
				<xsl:if test="child::*[local-name()='Type'] or child::*[local-name()='TypeCoded']">
					<div class="eh-col-1">
						<div class="eh-label">
							Type materiale
							<xsl:if test="$last!=1">
								&#160;<xsl:value-of select="$pos"/>
							</xsl:if>
						</div>
						<div class="eh-field">
							<!--Kommentar til en tilsynelatende for lang kolonnebredde: RequestedSubject, CollectedSample og CollectedStudyProduct er innenfor en choice -->
							<xsl:choose>
								<xsl:when test="child::*[local-name()='Type']">
									<xsl:value-of select="child::*[local-name()='Type']"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="child::*[local-name()='TypeCoded']">
										<xsl:choose>
											<xsl:when test="contains(@S, '8216')">
												<xsl:call-template name="k-8216"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="k-dummy"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='IdByRequester']">
					<div class="eh-col-1">
						<div class="eh-label">Rekvirents id</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='IdByRequester']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:for-each select="child::*[local-name()='RequestedSubject']">
					<xsl:if test="child::*[local-name()='Priority']">
						<div class="eh-col-1">
							<div class="eh-label">Prøvetakings&#173;prioritet</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='Priority']">
									<xsl:call-template name="k-8304"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='ReqDate']">
						<div class="eh-col-1">
							<div class="eh-label">Ønsket tidspunkt</div>
							<div class="eh-field">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='ReqDate']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='CollectedSample']">
					<xsl:if test="child::*[local-name()='CollectedDate']">
						<div class="eh-col-1">
						<div class="eh-label">Prøve tatt - dato</div>
							<div class="eh-field">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='CollectedDate']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='Logistics']">
						<div class="eh-col-1">
							<div class="eh-label">Forsendelsesmåte</div>
							<div class="eh-field">
								<xsl:value-of select="child::*[local-name()='Logistics']"/>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='CollectorComment'] or child::*[local-name()='CollectorCommentCoded']">
						<div class="eh-col-1">
							<div class="eh-label">Prøvetakers kommentar</div>
							<div class="eh-field">
								<xsl:if test="child::*[local-name()='CollectorComment']">
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="child::*[local-name()='CollectorComment']"/>
									</xsl:call-template>&#160;
								</xsl:if>
								<xsl:for-each select="child::*[local-name()='CollectorCommentCoded']">
									<xsl:choose>
										<xsl:when test="contains(@S, '8275')">
											<xsl:call-template name="k-8275"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="k-dummy"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='CollectedStudyProduct']">
					<xsl:if test="child::*[local-name()='Type']">
						<div class="eh-col-1">
							<div class="eh-label">Type analyseprodukt</div>
							<div class="eh-field">
								<xsl:value-of select="child::*[local-name()='Type']"/>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='ProducedDate']">
						<div class="eh-col-1">
							<div class="eh-label">Avledet prøve tatt - dato</div>
							<div class="eh-field">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='ProducedDate']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='RefRelatedProd']">
						<div class="eh-col-1">
							<div class="eh-label">Referanse til relatert produkt</div>
							<div class="eh-field">
								<xsl:value-of select="child::*[local-name()='RefRelatedProd']"/>
							</div>
						</div>
					</xsl:if>
				</xsl:for-each>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Number'] or child::*[local-name()='IdByServProv'] or child::*[local-name()='SampleCollInd'] or child::*[local-name()='SampleCollProc']">
			<div class="eh-row-4">
				<xsl:if test="child::*[local-name()='Number']">
					<div class="eh-col-1">
						<div class="eh-label">Antall</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Number']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='IdByServProv']">
					<div class="eh-col-1">
						<div class="eh-label">Tjeneste&#173;yters id</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='IdByServProv']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='SampleCollInd']">
					<div class="eh-col-1">
						<div class="eh-label">Prøve tatt</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='SampleCollInd']">
								<xsl:call-template name="k-1101"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='SampleCollProc']">
					<div class="eh-col-1">
						<div class="eh-label">Prøvetakings&#173;prosedyre</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='SampleCollProc']">
								<xsl:call-template name="k-dummy"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='AnatomicalOrigin'] or child::*[local-name()='PreservMaterial'] or child::*[local-name()='Pretreatment'] or child::*[local-name()='SubjectMeasures']">
			<div class="eh-row-4">
				<xsl:if test="child::*[local-name()='AnatomicalOrigin']">
					<div class="eh-col-1">
						<div class="eh-label">Anatomisk lokasjon</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='AnatomicalOrigin']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='PreservMaterial']">
					<div class="eh-col-1">
						<div class="eh-label">Konserverings-middel</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='PreservMaterial']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Pretreatment']"> <!-- maxOccurs="1" -->
					<div class="eh-col-1">
						<div class="eh-label">Forberedende behandling</div>
						<div class="eh-field blk">
							<xsl:for-each select="child::*[local-name()='Pretreatment']/child::*[local-name()='Heading']">
								<xsl:call-template name="k-8232"/>
							</xsl:for-each>
							<xsl:if test="child::*[local-name()='Pretreatment']/child::*[local-name()='TextResultValue']">
								<br/>
								<b>Beskrivelse: </b>
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="child::*[local-name()='Pretreatment']/child::*[local-name()='TextResultValue']"/>
								</xsl:call-template>
							</xsl:if>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='SubjectMeasures']"> <!-- maxOccurs="unbounded" -->
					<div class="eh-col-1">
						<div class="eh-label">Størrelse</div>
						<div class="eh-field blk">
							<xsl:for-each select="child::*[local-name()='SubjectMeasures']">
								<xsl:if test="position() &gt; 1">
									<br/>
								</xsl:if>
								<b>
									<xsl:value-of select="child::*[local-name()='TypeQuantity']"/>:&#160;
								</b>
								<xsl:value-of select="child::*[local-name()='Quantity']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='Quantity']/@U"/>&#160;
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='SampleHandling']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Håndterings&#173;beskrivelse</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='SampleHandling']"> <!-- maxOccurs="unbounded" -->
							<div style="padding-bottom: 8px;">
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="."/>
								</xsl:call-template>
							</div>
						</xsl:for-each>
					</div>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Comment']"> <!-- maxOccurs="1" -->
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
		<xsl:for-each select="child::*[local-name()='AnalysedSubject']"> <!-- rekursiv -->
			<xsl:call-template name="AnalysedSubject">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="InfItem">
		<xsl:param name="col"/>
		<xsl:variable name="type" select="child::*[local-name()='Type']/@V"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">
				<xsl:for-each select="child::*[local-name()='Type']">
					<xsl:call-template name="k-8233"/>
				</xsl:for-each>
			</div>
		</div>
		<xsl:if test="child::*[local-name()='Observation']/child::*[local-name()='Description'] or child::*[local-name()='Observation']/child::*[local-name()='CodedDescr'] or child::*[local-name()='StartDateTime'] or child::*[local-name()='EndDateTime'] or child::*[local-name()='OrgDate']">
			<div class="eh-row-4">
				<xsl:if test="child::*[local-name()='Observation']/child::*[local-name()='Description'] or child::*[local-name()='Observation']/child::*[local-name()='CodedDescr']">
					<div class="eh-col-1">
						<div class="eh-label">Beskrivelse</div>
						<div class="eh-field blk">
							<xsl:for-each select="child::*[local-name()='Observation']/child::*[local-name()='Description']">
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
							<xsl:if test="child::*[local-name()='Observation']/child::*[local-name()='CodedDescr']">
									<xsl:for-each select="child::*[local-name()='Observation']/child::*[local-name()='CodedDescr']">
										<xsl:choose>
											<xsl:when test="contains(@S, '8209')">
												<xsl:call-template name="k-8209"/>
											</xsl:when>
											<xsl:when test="contains(@S, '8210')">
												<xsl:call-template name="k-8210"/>
											</xsl:when>
											<xsl:when test="contains(@S, '8217')">
												<xsl:call-template name="k-8217"/>
											</xsl:when>
											<xsl:when test="contains(@S, '8218')">
												<xsl:call-template name="k-8218"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="k-dummy"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
							</xsl:if>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='StartDateTime']">
					<div class="eh-col-1">
						<div class="eh-label">Start-dato</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='EndDateTime']">
					<div class="eh-col-1">
						<div class="eh-label">Slutt-dato</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='OrgDate']">
					<div class="eh-col-1">
						<div class="eh-label">Opprinnelses-dato</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='OrgDate']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Observation']/child::*[local-name()='Comment']"> <!-- maxOccurs="1" -->
			<div class="eh-row-4">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Kommentar</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Observation']/child::*[local-name()='Comment']"/>
						</xsl:call-template>
					</div>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="ServProvider">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">Mottaker
				<xsl:if test="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']"> - Spesialitet:&#160;<xsl:for-each select="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']">
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

	<xsl:template name="Requester">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">Avsender
				<xsl:if test="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']"> - Spesialitet:&#160;<xsl:for-each select="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']">
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

	<xsl:template name="PaymentResponsible">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">Betalingsansvarlig
				<xsl:if test="child::*[local-name()='TypeGuarantor']"> - <xsl:value-of select="child::*[local-name()='TypeGuarantor']"/>
				</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="CopyDest">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">Kopimottaker
				<xsl:if test="child::*[local-name()='CopyDestRole']/child::*[local-name()='MsgType']"> - kopi&#160;av:&#160;<xsl:for-each select="child::*[local-name()='CopyDestRole']/child::*[local-name()='MsgType']">
						<xsl:call-template name="k-8236"/>
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

	<xsl:template name="ResponsibleHcp">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='Relation']">
						<xsl:for-each select="child::*[local-name()='Relation']">
							<xsl:choose>
								<xsl:when test="namespace-uri() = 'http://www.kith.no/xmlstds/rekvisisjon/2012-02-15'">
									<xsl:call-template name="k-8254"/> <!-- v1.6 -->
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="k-7319"/> <!-- v1.5 and below -->
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Ansvarlig&#160;helsetjenesteenhet</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="AdmLocation">
		<xsl:param name="col"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">Oppholdssted for pasient
				<xsl:if test="child::*[local-name()='AdmCat']"> - Type&#160;tjeneste:&#160;<xsl:for-each select="child::*[local-name()='AdmCat']">
						<xsl:call-template name="k-8240"/>
					</xsl:for-each>
				</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='Location']/child::*[local-name()='Inst']">
			<div class="eh-row-4">
				<xsl:call-template name="Inst">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Dept']">
			<div class="eh-row-4">
				<xsl:call-template name="Dept">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='HCPerson']">
			<div class="eh-row-4">
				<xsl:call-template name="HCPerson">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Location']/child::*[local-name()='Address']">
			<xsl:variable name="antall-tel" select="count(child::*[local-name()='TeleAddress'])"/>
			<div class="eh-row-4">
				<xsl:for-each select="child::*[local-name()='TeleAddress']">
					<xsl:call-template name="TeleAddress">
						<xsl:with-param name="col" select="(($col)-1)*number(not(child::*[local-name()='Type'] and (child::*[local-name()='PostalCode'] or child::*[local-name()='City'])))+1"/>
					</xsl:call-template>
				</xsl:for-each>
				<xsl:if test="child::*[local-name()='Type'] and (child::*[local-name()='PostalCode'] or child::*[local-name()='City'])">
					<xsl:call-template name="Address">
						<xsl:with-param name="col" select="($col)-1-($antall-tel)*2"/>
					</xsl:call-template>
				</xsl:if>
			</div>
		</xsl:for-each>
	</xsl:template>

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
					<xsl:call-template name="TeleAddress">
						<xsl:with-param name="col" select="(($col)-1)*number(not(child::*[local-name()='Type'] and (child::*[local-name()='PostalCode'] or child::*[local-name()='City'])))+1"/>
					</xsl:call-template>
				</xsl:for-each>
				<xsl:if test="child::*[local-name()='Type'] and (child::*[local-name()='PostalCode'] or child::*[local-name()='City'])">
					<xsl:call-template name="Address">
						<xsl:with-param name="col" select="($col)-1-($antall-tel)*2"/>
					</xsl:call-template>
				</xsl:if>
			</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="HCProf">
		<xsl:param name="col"/>
		<div class="eh-col-1">
			<div class="eh-label">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='Type']">
						<xsl:for-each select="child::*[local-name()='Type']">
							<xsl:call-template name="k-9060"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Helse&#173;personell</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="eh-field">
				<xsl:value-of select="child::*[local-name()='Name']"/>
			</div>
		</div>
		<div class="eh-col-1">
			<div class="eh-label">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='TypeId']">
						<xsl:for-each select="child::*[local-name()='TypeId']">
							<xsl:choose>
								<xsl:when test="namespace-uri() = 'http://www.kith.no/xmlstds/rekvisisjon/2012-02-15'">
									<xsl:call-template name="k-8116"/> <!-- v1.6 -->
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="k-8268"/> <!-- v1.5 and below -->
								</xsl:otherwise>
							</xsl:choose>
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
				<div class="eh-col-1">
					<xsl:call-template name="AdditionalId">
						<xsl:with-param name="col" select="true()"/>
					</xsl:call-template>
				</div>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Inst">
		<xsl:param name="col"/>
		<div class="eh-col-1">
			<div class="eh-label">Navn</div>
			<div class="eh-field">
				<xsl:value-of select="child::*[local-name()='Name']"/>
			</div>
		</div>
		<div class="eh-col-1">
			<div class="eh-label">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='TypeId']">
						<xsl:for-each select="child::*[local-name()='TypeId']">
							<xsl:choose>
								<xsl:when test="namespace-uri() = 'http://www.kith.no/xmlstds/rekvisisjon/2012-02-15'">
									<xsl:call-template name="k-9051"/> <!-- v1.6 -->
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="k-8268"/> <!-- v1.5 and below -->
								</xsl:otherwise>
							</xsl:choose>
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
				<div class="eh-col-1">
					<xsl:call-template name="AdditionalId">
						<xsl:with-param name="col" select="true()"/>
					</xsl:call-template>
				</div>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Dept">
		<xsl:param name="col"/>
		<div class="eh-col-1">
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
		<div class="eh-col-1">
			<div class="eh-label">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='TypeId']">
						<xsl:for-each select="child::*[local-name()='TypeId']">
							<xsl:choose>
								<xsl:when test="namespace-uri() = 'http://www.kith.no/xmlstds/rekvisisjon/2012-02-15'">
									<xsl:call-template name="k-9051"/> <!-- v1.6 -->
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="k-8268"/> <!-- v1.5 and below -->
								</xsl:otherwise>
							</xsl:choose>
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
				<div class="eh-col-1">
					<xsl:call-template name="AdditionalId">
						<xsl:with-param name="col" select="true()"/>
					</xsl:call-template>
				</div>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template name="HCPerson">
		<xsl:param name="col"/>
		<div class="eh-col-1">
			<div class="eh-label">Helse&#173;personell</div>
			<div class="eh-field">
				<xsl:value-of select="child::*[local-name()='Name']"/>
			</div>
		</div>
		<div class="eh-col-1">
			<div class="eh-label">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='TypeId']">
						<xsl:for-each select="child::*[local-name()='TypeId']">
						<xsl:choose>
							<xsl:when test="namespace-uri() = 'http://www.kith.no/xmlstds/rekvisisjon/2012-02-15'">
								<xsl:call-template name="k-8116"/> <!-- v1.6 -->
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="k-8268"/> <!-- v1.5 and below -->
							</xsl:otherwise>
						</xsl:choose>
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
				<div class="eh-col-1">
					<xsl:call-template name="AdditionalId">
						<xsl:with-param name="col" select="true()"/>
					</xsl:call-template>
				</div>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template name="AdditionalId">
		<xsl:param name="col"/>
		<xsl:variable name="cssClass1">
			<xsl:choose>
				<xsl:when test="$col">eh-label</xsl:when>
				<xsl:otherwise>eh-strong</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="cssClass2">
			<xsl:choose>
				<xsl:when test="$col">eh-field</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<span class="{$cssClass1}">
			<xsl:for-each select="child::*[local-name()='Type']">

				<xsl:choose>
					<xsl:when test="namespace-uri() = 'http://www.kith.no/xmlstds/rekvisisjon/2012-02-15'">
						<xsl:choose> <!-- v1.6 -->
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
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="k-8268"/> <!-- v1.5 and below -->
					</xsl:otherwise>
				</xsl:choose>

			</xsl:for-each>
		</span>
		<span class="{$cssClass2}">
			<xsl:value-of select="child::*[local-name()='Id']"/>
		</span>
	</xsl:template>

	<xsl:template name="Address">
		<xsl:param name="col"/>
		<div class="eh-col-1">
			<div class="eh-label">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='Type']">
						<xsl:for-each select="child::*[local-name()='Type']">
							<xsl:call-template name="k-3401"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Adresse</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="eh-field">
				<xsl:if test="child::*[local-name()='StreetAdr']">
					<xsl:value-of select="child::*[local-name()='StreetAdr']"/>,&#160;</xsl:if>
				<xsl:if test="child::*[local-name()='PostalCode']">
					<xsl:value-of select="child::*[local-name()='PostalCode']"/>
				</xsl:if>
				<xsl:if test="child::*[local-name()='City']">&#160;<xsl:value-of select="child::*[local-name()='City']"/>
				</xsl:if>
				<xsl:if test="child::*[local-name()='CityDistr']">,&#160;<xsl:for-each select="child::*[local-name()='CityDistr']">
						<xsl:call-template name="k-3403"/>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="child::*[local-name()='County']">,&#160;<xsl:for-each select="child::*[local-name()='County']">
						<xsl:call-template name="k-3402"/>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Country']">,&#160;<xsl:for-each select="child::*[local-name()='Country']">
						<xsl:call-template name="k-9043"/>
					</xsl:for-each>
				</xsl:if>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="TeleAddress">
		<xsl:param name="col"/>
		<div class="eh-col-1">
			<div class="eh-label">
				<xsl:choose>
					<xsl:when test="starts-with(@V, 'tel:') or starts-with(@V, 'callto:')">Telefon</xsl:when>
					<xsl:when test="starts-with(@V, 'fax:')">Faks</xsl:when>
					<xsl:when test="starts-with(@V, 'mailto:')">e-post</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before(@V, ':')"/>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="eh-field">
				<xsl:value-of select="substring-after(@V, ':')"/>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="RefDoc">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='MsgType'] or child::*[local-name()='Id'] or child::*[local-name()='IssueDate'] or child::*[local-name()='MimeType'] or child::*[local-name()='Compression']">
			<div class="eh-row-5">
				<xsl:if test="child::*[local-name()='MsgType']">
					<div class="eh-col-1">
						<div class="eh-label">Type</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='MsgType']">
								<xsl:choose>
									<xsl:when test="namespace-uri() = 'http://www.kith.no/xmlstds/rekvisisjon/2012-02-15'">
										<xsl:call-template name="k-8114"/> <!-- v1.6 -->
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="k-8278"/> <!-- v1.5 and below -->
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
						<div class="eh-field">
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
					<div class="eh-col-1">
						<div class="eh-label">Komprimering</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Compression']">
								<xsl:call-template name="k-1204"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Description']"> <!-- maxOccurs="1" -->
			<div class="eh-row-4">
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
		<xsl:if test="child::*[local-name()='Content'] or child::*[local-name()='FileReference']">
			<xsl:choose>
				<xsl:when test="contains(child::*[local-name()='MimeType'],'image')">
					<div class="eh-row-4">
						<div class="eh-col-1 eh-last-child">
							<div class="eh-label">Bilde</div>
							<xsl:choose>
								<xsl:when test="child::*[local-name()='FileReference']">
									<div class="eh-field">
										<img>
											<xsl:attribute name="src"><xsl:value-of select="child::*[local-name()='FileReference']"/></xsl:attribute>
											<xsl:attribute name="alt">Bilde fra ekstern URL</xsl:attribute>
										</img>
									</div>
								</xsl:when>
								<xsl:when test="child::*[local-name()='Content']">
									<div class="eh-field">
										<xsl:choose>
											<xsl:when test="child::*[local-name()='Content']/base:Base64Container">
												<img>
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
					</div>
				</xsl:when>
				<xsl:when test="contains(child::*[local-name()='MimeType'],'pdf') or contains(child::*[local-name()='MimeType'],'PDF')">
					<div class="eh-row-4">
						<div class="eh-col-1 eh-last-child">
							<div class="eh-label">pdf</div>
							<xsl:choose>
								<xsl:when test="child::*[local-name()='FileReference']">
									<div class="eh-field">
										<object>
											<xsl:attribute name="data"><xsl:value-of select="concat(child::*[local-name()='FileReference'],'&#35;view&#61;FitH&#38;toolbar&#61;1')"/></xsl:attribute>
											<xsl:attribute name="type">application/pdf</xsl:attribute>
											<xsl:attribute name="width">100%</xsl:attribute>
											<xsl:attribute name="height">500px</xsl:attribute>
										</object>
									</div>
								</xsl:when>
								<xsl:when test="child::*[local-name()='Content']">
									<div class="eh-field">
										<xsl:choose>
											<xsl:when test="child::*[local-name()='Content']/base:Base64Container">
												<object>
													<xsl:attribute name="data"><xsl:value-of select="concat('data:application/pdf;base64,',child::*[local-name()='Content']/base:Base64Container)"/></xsl:attribute>
													<xsl:attribute name="type">application/pdf</xsl:attribute>
													<xsl:attribute name="width">100%</xsl:attribute>
													<xsl:attribute name="height">500px</xsl:attribute>
												</object>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="child::*[local-name()='Content']"/>
											</xsl:otherwise>
										</xsl:choose>
									</div>
								</xsl:when>
							</xsl:choose>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="eh-row-4">
						<div class="eh-col-1 eh-last-child">
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

	<xsl:template name="EgetBunnTillegg">
	</xsl:template>
	<xsl:template name="Diagnosis-DiagComment-CodedDescr-CodedComment">
	</xsl:template>

</xsl:stylesheet>
