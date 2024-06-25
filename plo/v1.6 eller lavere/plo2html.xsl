<?xml version="1.0" encoding="UTF-8"?>
	<!-- Endringslogg
	- 09.08.22: v3.3.0: Semantisk HTML
	- 04.06.21: v3.2.1: Lagt til xsl:output for å definere at output formatet skal være html
	- 01.06.17: v3.2.0: Responsiv visning.
	- 27.03.17: v3.1.1: Ny parameter for "visningStil. Ny stil "Smooth".
	- 25.10.16: v3.1.0: La til visningsversjonnr
	- 02.12.15: Generalisert til å håndtere alle plo-versjoner opp til v1.6
	- 01.12.15: Oppdatering for bruk av poKomponent uten navnerom. Innføring av felles kodeverksfil. Småjustering på layout.
	- 01.10.12: Oppdatert til versjon 1.6
	-->
	<!-- Om
	- Inngår i Hdirs visningsfiler versjon 2.0
	- Laget i XMLSpy v2016 (http://www.altova.com) av Jan Sigurd Dragsjø (nhn.no)
	-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24"
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1"
	exclude-result-prefixes="mh fk1">

	<xsl:import href="../../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../../felleskomponenter/poKomponent2html.xsl"/>
	<xsl:import href="../../felleskomponenter/cave2html.xsl"/>
	<xsl:import href="../../felleskomponenter/journalnotat2html.xsl"/>
	<xsl:import href="../../felleskomponenter/legemiddel2html.xsl"/>
	<xsl:import href="../../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../../felleskomponenter/eh-komponent1.xsl"/>
	<xsl:import href="../../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<xsl:variable name="versjon" select="'plo1.6 - v3.3.0'"/>
	
	<xsl:variable name="IsTestMessage" select="boolean(/mh:MsgHead/mh:MsgInfo/mh:ProcessingStatus[@V = 'D'])" />

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
				<title>PLO</title>
				<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
				<style type="text/css">
					<xsl:value-of select="document('../../felleskomponenter/KITH-visning.css')" disable-output-escaping="yes"/>
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../../felleskomponenter/ehelse-visning.css')" disable-output-escaping="yes"/>
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../../felleskomponenter/smooth-visning.css')" disable-output-escaping="yes"/>
				</style>
			</head>
			<body>
				<xsl:if test="$IsTestMessage">
					<p class="TestMessageWarning">OBS: Dette er en testmelding.</p>
				</xsl:if>
				<xsl:for-each select="mh:MsgHead">
					<xsl:call-template name="MsgHead"/>
				</xsl:for-each>
			</body>
		</html>
	</xsl:template>

	<!-- Visning av meldingshodet. Tilpasset vinduskonvolutt ved utskrift -->
	<xsl:template name="MsgHead">
		<xsl:call-template name="Topp"/>
		<xsl:call-template name="Innhold">
			<xsl:with-param name="menylinje" select="$menylinje"/>
		</xsl:call-template>
		<xsl:call-template name="Footer">
			<xsl:with-param name="stil" select="$stil"/>
			<xsl:with-param name="versjon" select="$versjon"/>
			<xsl:with-param name="VisDokInfoVisSkjul" select="false()"/>
		</xsl:call-template>
	</xsl:template>

	<!-- Visning av innhold -->
	<xsl:template name="Innhold">
		<main class="{$stil}">
			<!-- Overskrift for meldingen -->
			<h1>
				<xsl:for-each select="//mh:MsgInfo/mh:Type">
					<xsl:call-template name="k-8279"/>&#160;
				</xsl:for-each>
				<xsl:for-each select="//child::*[local-name()='TypeInnholdKonsultasjon']">-&#160;
					<xsl:choose>
						<xsl:when test="contains(@S, '9137')"><xsl:call-template name="k-9137"/></xsl:when>
						<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
					</xsl:choose>&#160;
				</xsl:for-each>
				<xsl:for-each select="//child::*[local-name()='TypeInnhold']">-&#160;
					<xsl:choose>
						<xsl:when test="contains(@S, '9138')"><xsl:call-template name="k-9138"/></xsl:when>
						<xsl:when test="contains(@S, '9139')"><xsl:call-template name="k-9139"/></xsl:when>
						<xsl:when test="contains(@S, '9140')"><xsl:call-template name="k-9140"/></xsl:when>
						<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
					</xsl:choose>&#160;
				</xsl:for-each>
				<xsl:if test="//child::*[local-name()='Forsendelsesstatus']">
					<xsl:if test="not(//child::*[local-name()='Forsendelsesstatus'][@V='N' or @V='X' or @V='O'])">-&#160;
						<xsl:for-each select="//child::*[local-name()='Forsendelsesstatus']">
							<xsl:call-template name="k-7309"/>
						</xsl:for-each>
					</xsl:if>
				</xsl:if>
			</h1>
			<xsl:if test="$menylinje = 'true'">
				<xsl:call-template name="FellesMeny"/>
			</xsl:if>
			<xsl:call-template name="Dokument"/>
		</main>
	</xsl:template>

	<!-- Visning av klikkbar overskriftsliste. Ikke synlig ved utskrift -->
	<xsl:template name="FellesMeny">
		<nav id="FellesMeny" class="FellesMeny NoPrint">
			<ul>
				<xsl:if test="//child::*[local-name()='InfoMedisinskDiagnose']">
					<li>
						<a href="#InfoMedisinskDiagnose">Medisinske&#160;diagnoser</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfoIPLOSrelevantInformasjon']">
					<li>
						<a href="#InfoIPLOSrelevantInformasjon">IPLOSrelevant&#160;informasjon</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='MedisinskfagligeOpplysninger']">
					<li>
						<a href="#MedisinskfagligeOpplysninger">Medisinskfaglige&#160;opplysninger</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfoAndreViktigeOpplysninger']">
					<li>
						<a href="#InfoAndreViktigeOpplysninger">Andre&#160;viktige&#160;opplysninger</a>
					</li>
				</xsl:if>
				<xsl:if test="//mh:Content/child::*[local-name()='Cave']">
					<li>
						<a href="#Cave">Cave/allergier</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Legemiddelinfo']">
					<li>
						<a href="#Legemiddelinfo">Legemidler</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='LegemidlerAdministrertVedOverforing']">
					<li>
						<a href="#LegemidlerAdministrertVedOverforing">Legemidler administrert ved overføring/utskrivning</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='Sykepleierdokumentasjon']">
					<li>
						<a href="#Sykepleierdokumentasjon">Sykepleieopplysninger</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='OpplysningerAndreFaggrupper']">
					<li>
						<a href="#OpplysningerAndreFaggrupper">Opplysninger&#160;fra&#160;andre&#160;faggrupper</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfoKartleggingFunksjonsniva']">
					<li>
						<a href="#InfoKartleggingFunksjonsniva">Kartlegging&#160;av&#160;funksjonsnivå</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfoReservasjon']">
					<li>
						<a href="#InfoReservasjon">Reservasjoner</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='TjenesteBehov']">
					<li>
						<a href="#TjenesteBehov">Behov&#160;for&#160;tjenester</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfoKontrolltime']">
					<li>
						<a href="#InfoKontrolltime">Kontrolltime</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='OrienteringOmDod'] or //child::*[local-name()='MeldingOmUtskrevetPasient'] or //child::*[local-name()='MeldingUtskrivningsklarPasient'] or //child::*[local-name()='AvmeldingUtskrivningsklarPasient'] or //child::*[local-name()='MeldingInnlagtPasient']">
					<xsl:if test="//child::*[local-name()='TidsfestetHendelse']">
						<li>
							<a href="#TidsfestetHendelse">Tidsfestet&#160;hendelse</a>
						</li>
					</xsl:if>
					<xsl:if test="//child::*[local-name()='UtskrevetTil']">
						<li>
							<a href="#UtskrevetTil">Utskrevet&#160;til</a>
						</li>
					</xsl:if>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfoInformasjonGitt']">
					<li>
						<a href="#InfoInformasjonGitt">Informasjon&#160;gitt</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='OpplysningerOmHjelpemidler']">
					<li>
						<a href="#OpplysningerOmHjelpemidler">Hjelpemidler</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='OpplysningOpphold']">
					<li>
						<a href="#OpplysningOpphold">Opplysninger&#160;om&#160;opphold</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='EksisterendeTjeneste']">
					<li>
						<a href="#EksisterendeTjeneste">Eksisterende&#160;tjenester</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='InfoAssistertKommunikasjon']">
					<li>
						<a href="#InfoAssistertKommunikasjon">Assistert&#160;kommunikasjon</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='TilleggsopplysningPasient']">
					<li>
						<a href="#TilleggsopplysningPasient">Andre&#160;pasientopplysninger</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='ParorendeForesatt']">
					<li>
						<a href="#ParorendeForesatt">Pårørende/foresatte</a>
					</li>
				</xsl:if>
				<xsl:if test="//mh:Content/child::*[local-name()='Notater']">
					<li>
						<a href="#AndreNotater">Andre notater</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='TilknyttetEnhet']">
					<li>
						<a href="#TilknyttetEnhet">Kontaktinformasjon&#160;virksomhet</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='KontaktpersonHelsepersonell']">
					<li>
						<a href="#KontaktpersonHelsepersonell">Kontaktpersoner&#160;helsepersonell</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='AnsvarForRapport']">
					<li>
						<a href="#AnsvarForRapport">Ansvar&#160;for&#160;rapport</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='SendtDokument']">
					<li>
						<a href="#SendtDokument">Tilknyttet&#160;dokument</a>
					</li>
				</xsl:if>
				<xsl:if test="//child::*[local-name()='OpplysningerTilSoknad']">
					<li>
						<a href="#OpplysningerTilSoknad">Opplysninger&#160;til&#160;søknad</a>
					</li>
				</xsl:if>
				<xsl:if test="count(//mh:RefDoc) &gt; 1">
					<li>
						<a href="#Vedlegg">Vedlegg</a>
					</li>
				</xsl:if>
			</ul>
		</nav>
	</xsl:template>

	<!-- Visning av vedlagte dokument -->
	<xsl:template name="Dokument">
		<!-- Tabell og overskrift for Medisinske diagnoser -->
		<xsl:if test="//child::*[local-name()='InfoMedisinskDiagnose']">
			<section>
				<h2 id="InfoMedisinskDiagnose">Medisinske&#160;diagnoser</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='InfoMedisinskDiagnose']">
						<xsl:call-template name="InfoMedisinskDiagnose"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for IPLOSrelevant informasjon -->
		<xsl:if test="//child::*[local-name()='InfoIPLOSrelevantInformasjon']">
			<section>
				<h2 id="InfoIPLOSrelevantInformasjon">IPLOSrelevant&#160;informasjon</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='InfoIPLOSrelevantInformasjon']">
						<xsl:call-template name="InfoIPLOSrelevantInformasjon"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Medisinskfaglige opplysninger -->
		<xsl:if test="//child::*[local-name()='MedisinskfagligeOpplysninger']">
			<section>
				<h2 id="MedisinskfagligeOpplysninger">Medisinskfaglige&#160;opplysninger</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='MedisinskfagligeOpplysninger']">
						<xsl:call-template name="MedisinskfagligeOpplysninger"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Andre viktige opplysninger -->
		<xsl:if test="//child::*[local-name()='InfoAndreViktigeOpplysninger']">
			<section>
				<h2 id="InfoAndreViktigeOpplysninger">Andre&#160;viktige&#160;opplysninger</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='InfoAndreViktigeOpplysninger']">
						<xsl:call-template name="InfoAndreViktigeOpplysninger"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Cave/allergier -->
		<xsl:if test="//mh:Content/child::*[local-name()='Cave']">
			<section>
				<h2 id="Cave">Cave/allergier</h2>
				<div class="eh-section">
					<xsl:for-each select="//mh:Content/child::*[local-name()='Cave']">
						<xsl:call-template name="Cave"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Legemidler -->
		<xsl:if test="//child::*[local-name()='Legemiddelinfo']">
			<section>
				<h2 id="Legemiddelinfo">Legemidler</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='Legemiddelinfo']">
						<xsl:call-template name="Legemiddelinfo"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Administrerte legemidler -->
		<xsl:if test="//child::*[local-name()='LegemidlerAdministrertVedOverforing']">
			<section>
				<h2 id="LegemidlerAdministrertVedOverforing">Legemidler administrert ved overføring/utskrivning</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='LegemidlerAdministrertVedOverforing']">
						<xsl:call-template name="LegemidlerAdministrertVedOverforing"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Sykepleieopplysninger -->
		<xsl:if test="//child::*[local-name()='Sykepleierdokumentasjon']">
			<section>
				<h2 id="Sykepleierdokumentasjon">Sykepleieopplysninger</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='Sykepleierdokumentasjon']">
						<xsl:call-template name="Sykepleierdokumentasjon"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Opplysninger fra andre faggrupper -->
		<xsl:if test="//child::*[local-name()='OpplysningerAndreFaggrupper']">
			<section>
				<h2 id="OpplysningerAndreFaggrupper">Opplysninger&#160;fra&#160;andre&#160;faggrupper</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='OpplysningerAndreFaggrupper']">
						<xsl:call-template name="OpplysningerAndreFaggrupper"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Kartlegging av funksjonsnivå -->
		<xsl:if test="//child::*[local-name()='InfoKartleggingFunksjonsniva']">
			<section>
				<h2 id="InfoKartleggingFunksjonsniva">Kartlegging&#160;av&#160;funksjonsnivå</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='InfoKartleggingFunksjonsniva']">
						<xsl:call-template name="InfoKartleggingFunksjonsniva"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Reservasjoner -->
		<xsl:if test="//child::*[local-name()='InfoReservasjon']">
			<section>
				<h2 id="InfoReservasjon">Reservasjoner</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='InfoReservasjon']">
						<xsl:call-template name="InfoReservasjon"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Behov for tjenester -->
		<xsl:if test="//child::*[local-name()='TjenesteBehov']">
			<section>
				<h2 id="TjenesteBehov">Behov for tjenester</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='TjenesteBehov']">
						<xsl:call-template name="TjenesteBehov"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Kontrolltime -->
		<xsl:if test="//child::*[local-name()='InfoKontrolltime']">
			<section>
				<h2 id="InfoKontrolltime">Kontrolltime</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='InfoKontrolltime']">	<!-- TverrfagligEpikrise: maxOccurs="unbounded" -->
						<xsl:call-template name="InfoKontrolltime"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Pasientlogistikk-meldingene -->
		<xsl:if test="//child::*[local-name()='OrienteringOmDod'] or //child::*[local-name()='MeldingOmUtskrevetPasient'] or //child::*[local-name()='MeldingUtskrivningsklarPasient'] or //child::*[local-name()='AvmeldingUtskrivningsklarPasient'] or //child::*[local-name()='MeldingInnlagtPasient']">
			<xsl:if test="//child::*[local-name()='TidsfestetHendelse']">
				<section>
					<h2 id="TidsfestetHendelse">Tidsfestet hendelse</h2>
					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='TidsfestetHendelse']"> <!-- maxOccurs="1 eller unbounded" -->
							<xsl:call-template name="TidsfestetHendelse"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>
			<xsl:if test="//child::*[local-name()='UtskrevetTil']">
				<section>
					<h2 id="UtskrevetTil">Utskrevet til</h2>
					<div class="eh-section">
						<xsl:for-each select="//child::*[local-name()='UtskrevetTil']">			<!-- maxOccurs="1" -->
							<xsl:call-template name="UtskrevetTil"/>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>
		</xsl:if>
		<!-- Tabell og overskrift for Informasjon gitt -->
		<xsl:if test="//child::*[local-name()='InfoInformasjonGitt']">
			<section>
				<h2 id="InfoInformasjonGitt">Informasjon gitt</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='InfoInformasjonGitt']">		<!-- maxOccurs="unbounded" -->
						<xsl:call-template name="InfoInformasjonGitt"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Hjelpemidler -->
		<xsl:if test="//child::*[local-name()='OpplysningerOmHjelpemidler']">
			<section>
				<h2 id="OpplysningerOmHjelpemidler">Hjelpemidler</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='OpplysningerOmHjelpemidler']">	<!-- maxOccurs="1" -->
						<xsl:call-template name="OpplysningerOmHjelpemidler"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Opplysninger om opphold -->
		<xsl:if test="//child::*[local-name()='OpplysningOpphold']">
			<section>
				<h2 id="OpplysningOpphold">Opplysninger om opphold</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='OpplysningOpphold']">	<!-- maxOccurs="unbounded" -->
						<xsl:call-template name="OpplysningOpphold">
							<xsl:with-param name="stripedCss">
								<xsl:choose>
									<xsl:when test="boolean(position() mod 2)"></xsl:when>
									<xsl:otherwise>striped</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Eksisterende tjenester -->
		<xsl:if test="//child::*[local-name()='EksisterendeTjeneste']">
			<section>
				<h2 id="EksisterendeTjeneste">Eksisterende tjenester</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='EksisterendeTjeneste']">	<!-- maxOccurs="unbounded" -->
						<xsl:call-template name="EksisterendeTjeneste">
							<xsl:with-param name="stripedCss">
								<xsl:choose>
									<xsl:when test="boolean(position() mod 2)"></xsl:when>
									<xsl:otherwise>striped</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Assistert kommunikasjon -->
		<xsl:if test="//child::*[local-name()='InfoAssistertKommunikasjon']">
			<section>
				<h2 id="InfoAssistertKommunikasjon">Assistert kommunikasjon</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='InfoAssistertKommunikasjon']">	<!-- maxOccurs="1 eller unbounded" -->
						<xsl:call-template name="InfoAssistertKommunikasjon">
							<xsl:with-param name="stripedCss">
								<xsl:choose>
									<xsl:when test="boolean(position() mod 2)"></xsl:when>
									<xsl:otherwise>striped</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Andre pasientopplysninger -->
		<xsl:if test="//child::*[local-name()='TilleggsopplysningPasient']">
			<section>
				<h2 id="TilleggsopplysningPasient">Andre pasientopplysninger</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='TilleggsopplysningPasient']">	<!-- maxOccurs="1" -->
						<xsl:call-template name="TilleggsopplysningPasient"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Pårørende/foresatte -->
		<xsl:if test="//child::*[local-name()='ParorendeForesatt']">
			<section>
				<h2 id="ParorendeForesatt">Pårørende/foresatte</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='ParorendeForesatt']">		<!-- maxOccurs="unbounded" -->
						<xsl:call-template name="ParorendeForesatt">
							<xsl:with-param name="stripedCss">
								<xsl:choose>
									<xsl:when test="boolean(position() mod 2)"></xsl:when>
									<xsl:otherwise>striped</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Andre notater -->
		<xsl:if test="//mh:Content/child::*[local-name()='Notater']">
			<section>
				<h2 id="AndreNotater">Andre notater</h2>
				<div class="eh-section">
					<xsl:for-each select="//mh:Content/child::*[local-name()='Notater']">		<!-- Content : type="anyType" -->
						<xsl:call-template name="Notater"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Kontaktinformasjon virksomhet -->
		<xsl:if test="//child::*[local-name()='TilknyttetEnhet']">
			<section>
				<h2 id="TilknyttetEnhet">Kontaktinformasjon virksomhet</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='TilknyttetEnhet']">		<!-- maxOccurs="unbounded" -->
						<xsl:call-template name="TilknyttetEnhet">
							<xsl:with-param name="stripedCss">
								<xsl:choose>
									<xsl:when test="boolean(position() mod 2)"></xsl:when>
									<xsl:otherwise>striped</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Kontaktpersoner helsepersonell -->
		<xsl:if test="//child::*[local-name()='KontaktpersonHelsepersonell']">
			<section>
				<h2 id="KontaktpersonHelsepersonell">Kontaktpersoner helsepersonell</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='KontaktpersonHelsepersonell']">		<!-- maxOccurs="unbounded" -->
						<xsl:call-template name="KontaktpersonHelsepersonell">
							<xsl:with-param name="stripedCss">
								<xsl:choose>
									<xsl:when test="boolean(position() mod 2)"></xsl:when>
									<xsl:otherwise>striped</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Ansvar for rapport -->
		<xsl:if test="//child::*[local-name()='AnsvarForRapport']">
			<section>
				<h2 id="AnsvarForRapport">Ansvar for rapport</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='AnsvarForRapport']">			<!-- maxOccurs="unbounded" -->
						<xsl:call-template name="AnsvarForRapport">
							<xsl:with-param name="stripedCss">
								<xsl:choose>
									<xsl:when test="boolean(position() mod 2)"></xsl:when>
									<xsl:otherwise>striped</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Sendt dokument -->
		<xsl:if test="//child::*[local-name()='SendtDokument']">
			<section>
				<h2 id="SendtDokument">Tilknyttet dokument</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='SendtDokument']">		<!-- maxOccurs="unbounded" -->
						<xsl:call-template name="SendtDokument">
							<xsl:with-param name="stripedCss">
								<xsl:choose>
									<xsl:when test="boolean(position() mod 2)"></xsl:when>
									<xsl:otherwise>striped</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<!-- Tabell og overskrift for Opplysninger til søknad -->
		<xsl:if test="//child::*[local-name()='OpplysningerTilSoknad']">
			<section>
				<h2 id="OpplysningerTilSoknad">Opplysninger&#160;til&#160;søknad</h2>
				<div class="eh-section">
					<xsl:for-each select="//child::*[local-name()='OpplysningerTilSoknad']">	<!-- maxOccurs="1" -->
						<xsl:call-template name="OpplysningerTilSoknad"/>
					</xsl:for-each>
				</div>
			</section>
		</xsl:if>
		<xsl:if test="count(//mh:RefDoc) &gt; 1">
			<xsl:for-each select="//mh:RefDoc">
				<xsl:if test="position() != 1">
					<section>
						<h2 id="Vedlegg">Vedlegg</h2>
						<div class="eh-section">
							<xsl:call-template name="eh-RefDoc"/>
						</div>
					</section>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<!-- Template som kalles fra BunnTillegg i meldingshodet. Kan brukes til visning av egenkomponert bunn -->
	<xsl:template name="EgetBunnTillegg">
		<xsl:for-each select="//child::*[local-name()='InformasjonOmForsendelsen']">
			<xsl:call-template name="InformasjonOmForsendelsen"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="Diagnosis-DiagComment-CodedDescr-CodedComment" />

</xsl:stylesheet>
