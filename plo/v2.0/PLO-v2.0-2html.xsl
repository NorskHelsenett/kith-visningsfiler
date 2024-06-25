<?xml version="1.0" encoding="UTF-8"?>
<!-- Inngår i Hdirs visningsfiler versjon 1.0

	FORMÅL
	XSLT for generering av html-visning av plo-meldinger v2.0

	ENDRINGER:
	27.03.2017: v3.1.1: Ny parameter for "visningStil. Ny stil "Smooth".
	25.10.2016: v3.1.0: La til visningsversjonnr
	27.10.2015: Første versjon
	
	SVAKHETER
	- Hardkodet enkelte headere utifra nåværende kodeverk. Hvis kodeverket endres, må også visningsfilen endres.

	Laget i XMLSpy v2012 rel2 (http://www.altova.com) av 
	v2.0: Jørgen Wilhelmsen (helsedirektoratet.no)
	v1.6: Jan Sigurd Dragsjø (helsedirektoratet.no) 
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:po="http://www.kith.no/xmlstds/po/poKomponent/2015-xx-xx" 
	xmlns:p1="http://www.kith.no/xmlstds/po/Pasientlogistikk/2015-xx-xx" 
	xmlns:p3="http://www.kith.no/xmlstds/po/OrienteringOmTjenestetilbud/2015-xx-xx" 
	xmlns:p5="http://www.kith.no/xmlstds/po/HelseopplysningerVedSoknad/2012-04-01" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:epj1="http://www.kith.no/xmlstds/epj/epj1/2008-02-20" 
	xmlns:epj2="http://www.kith.no/xmlstds/epj/epj2/2008-02-20" 
	xmlns:epj3="http://www.kith.no/xmlstds/epj/epj3/2008-02-20" 
	xmlns:m25="http://www.kith.no/xmlstds/eresept/m251/2013-10-08" 
	exclude-result-prefixes="po mh p1 p3 p5 fk1 epj1 epj2 epj3 m25">
	
	<xsl:import href="../../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../../felleskomponenter/poKomponent2html.xsl"/>
	<xsl:import href="../../felleskomponenter/cave2html.xsl"/>
	<xsl:import href="../../felleskomponenter/journalnotat2html.xsl"/>
	<xsl:import href="../../felleskomponenter/legemiddel2html.xsl"/>
	<xsl:import href="../../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../../eresept/m25/m25-2html-v2.5.xsl"/>
	<xsl:import href="../../felleskomponenter/visningstil.xsl"/>


	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'plo2.0 - v3.1.1 '"/>
	
		<xsl:variable name="IsTestMessage" select="boolean(/mh:MsgHead/mh:MsgInfo/mh:ProcessingStatus[@V = 'D'])" />

	<!-- html oppsett -->
	<xsl:template match="/">
		<html>
			<head>
				<title>PLO</title>
				<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
				<style type="text/css">
					<xsl:value-of select="document('../../felleskomponenter/KITH-visning.css')" disable-output-escaping="yes"/>
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../../felleskomponenter/smooth-visning.css')" disable-output-escaping="yes"/>
				</style>
			</head>
			<body>
				<xsl:if test="$IsTestMessage">
					<p class="TestMessageWarning">OBS: Dette er en testmelding.</p>
				</xsl:if>
				<xsl:apply-templates select="mh:MsgHead"/>
			</body>
		</html>
	</xsl:template>
	<!-- Visning av meldingshodet. Tilpasset vinduskonvolutt ved utskrift -->
	<xsl:template match="mh:MsgHead">
		<xsl:call-template name="Topp"/>
		<xsl:call-template name="InnholdPLO"/>
		<xsl:choose>
			<xsl:when test="//po:InformasjonOmForsendelsen">
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
		<xsl:call-template name="m25vedlegg"/>
	</xsl:template>
	<xsl:template name="EgetBunnTillegg">
		<xsl:for-each select="//po:InformasjonOmForsendelsen">
			<xsl:apply-templates select="."/>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av innhold -->
	<xsl:template name="InnholdPLO">
		<div class="{$stil}">
			<!-- Overskrift for meldingen -->
			<h1>
				<!--Kodeverk 8279 istedenfor???-->
				<xsl:choose>
					<xsl:when test="//mh:MsgInfo[mh:Type/@V='SAMMENFATNING']">Sammenfatning</xsl:when>
					<xsl:when test="//mh:MsgInfo[mh:Type/@V='LIB']">Legemidler i bruk</xsl:when>
					<xsl:when test="//mh:MsgInfo[mh:Type/@V='ORIENTERING_TJENESTETILBUD']">Orientering om tjenestetilbud</xsl:when>
					<!--<xsl:when test="//mh:MsgInfo[mh:Type/@V='LEGEMIDDELHANDTERING']">Legemiddelhåndtering</xsl:when>-->
					<xsl:when test="//mh:MsgInfo[mh:Type/@V='LOG_INNLAGT']">Melding&#160;om&#160;innlagt&#160;pasient</xsl:when>
					<xsl:when test="//mh:MsgInfo[mh:Type/@V='LOG_AVMELDING']">Avmelding&#160;av&#160;utskrivningsklar&#160;pasient</xsl:when>
					<xsl:when test="//mh:MsgInfo[mh:Type/@V='LOG_DOD']">Orientering&#160;om&#160;dødsfall</xsl:when>
					<xsl:when test="//mh:MsgInfo[mh:Type/@V='LOG_UTSKREVET']">Melding&#160;om&#160;utskrevet&#160;pasient</xsl:when>
					<xsl:when test="//mh:MsgInfo[mh:Type/@V='LOG_UTSKRIVNINGSKLAR']">Melding&#160;om&#160;utskrivningsklar&#160;pasient</xsl:when>
					<xsl:when test="//mh:MsgInfo[mh:Type/@V='LOG_TILBAKEMELDING']">Tilbakemelding på utskrivningsklar pasient</xsl:when>
					<xsl:when test="//mh:MsgInfo[mh:Type/@V='HELSEOPPL_SOKNAD']">Helseopplysninger</xsl:when>
					<xsl:when test="//mh:MsgInfo/mh:Type/@DN">
						<xsl:value-of select="//mh:MsgInfo/mh:Type/@DN"/>
					</xsl:when>
					<xsl:otherwise>PLO-melding:&#160;<xsl:value-of select="//mh:MsgInfo/mh:Type/@V"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:for-each select="//po:TypeInnhold">
						&#160;-&#160;
					<xsl:choose>
					<!--TODO: input ordentlig kodeverdi for sammenfatning når det er på plass. 9140 er for helseopplysninger saksbehandling-->
						<xsl:when test="contains(@S, '9140')">
							<xsl:call-template name="k-9140"/>
						</xsl:when>
						<xsl:when test="@DN">
							<xsl:value-of select="@DN"/>
						</xsl:when>
					</xsl:choose>
					<xsl:if test="po:Merknad"> - <xsl:value-of select="po:Merknad"/></xsl:if>
				</xsl:for-each>
				<xsl:if test="//po:Forsendelsesstatus">
					<xsl:if test="not(//po:Forsendelsesstatus[@V='N' or @V='X' or @V='O'])">
						&#160;-&#160;
						<xsl:for-each select="//po:Forsendelsesstatus">
							<fo:inline color="#FF0000">(<xsl:call-template name="k-7309"/>)</fo:inline>
						</xsl:for-each>
					</xsl:if>
				</xsl:if>
			</h1>
			<xsl:call-template name="FellesMenyPLO"/>
			<xsl:call-template name="DokumentPLO"/>
		</div>
	</xsl:template>
	<!-- Visning av klikkbar overskriftsliste. Ikke synlig ved utskrift -->
	<xsl:template name="FellesMenyPLO">
		<div class="NoPrint">
			<div id="FellesMeny" class="FellesMeny">
				<ul>
					<!--NB! Hardkodet kodeverk. Hvis kodeverk 9142 endres, må linjen under endres også-->
					<xsl:if test="//epj2:GenereltJournalnotat[.//epj2:Overskriftskode[@V='PROB']]">
						<li>
							<a href="#Problemstilling">Aktuell &#160;problemstilling</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:InfoMedisinskDiagnose">
						<li>
							<a href="#InfoMedisinskDiagnose">Medisinske&#160;diagnoser</a>
						</li>
					</xsl:if>
					<!--NB! Hardkodet kodeverk. Hvis kodeverk 9142 endres, må linjen under endres også-->
					<xsl:if test="//epj2:GenereltJournalnotat[.//epj2:Overskriftskode[@V='TS']]">
						<li>
							<a href="#Andre relevante tilstander">Andre relevante tilstander</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:InfoIPLOSrelevantInformasjon">
						<li>
							<a href="#InfoIPLOSrelevantInformasjon">IPLOSrelevant&#160;informasjon</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:InfoAndreViktigeOpplysninger or //epj1:Cave">
						<li>
							<a href="#ViktigeOpplysninger">Viktige opplysninger</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:Legemiddelhandtering">
						<li>
							<a href="#LegemiddelOpplysninger">Legemiddelopplysninger</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:OpplysningerRelevantOppfolging">
						<li>
							<a href="#OpplysningerRelevantOppfolging">Relevant oppfølging</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:OpplysningerAndreFaggrupper">
						<li>
							<a href="#OpplysningerAndreFaggrupper">Opplysninger&#160;fra&#160;andre&#160;faggrupper</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:InfoKartleggingFunksjonsniva">
						<li>
							<a href="#InfoKartleggingFunksjonsniva">Funksjonsbeskrivelse</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:OpplysningerOmHjelpemidler">
						<li>
							<a href="#OpplysningerOmHjelpemidler">Hjelpemidler</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:InfoReservasjon">
						<li>
							<a href="#InfoReservasjon">Reservasjoner</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:TjenesteBehov">
						<li>
							<a href="#TjenesteBehov">Behov&#160;for&#160;tjenester</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:InfoKontrolltime">
						<li>
							<a href="#InfoKontrolltime">Kontrolltime</a>
						</li>
					</xsl:if>
					<xsl:if test="//p1:OrienteringOmDod or //p1:MeldingOmUtskrevetPasient or //p1:MeldingUtskrivningsklarPasient or //p1:AvmeldingUtskrivningsklarPasient or //p1:MeldingInnlagtPasient">
						<xsl:if test="//po:TidsfestetHendelse">
							<li>
								<a href="#TidsfestetHendelse">Tidsfestet&#160;hendelse</a>
							</li>
						</xsl:if>
						<xsl:if test="//po:UtskrevetTil">
							<li>
								<a href="#UtskrevetTil">Utskrevet&#160;til</a>
							</li>
						</xsl:if>
					</xsl:if>
					<xsl:if test="//po:InfoInformasjonGitt">
						<li>
							<a href="#InfoInformasjonGitt">Informasjon&#160;gitt</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:OpplysningOpphold">
						<li>
							<a href="#OpplysningOpphold">Opplysninger&#160;om&#160;opphold/konsultasjon</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:EksisterendeTjeneste">
						<li>
							<a href="#EksisterendeTjeneste">Eksisterende&#160;tjenester</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:TilleggsopplysningPasient or //po:AssistertKommunikasjon or //po:ParorendeForesatt or //po:PasientrelatertKontaktperson">
						<li>
							<a href="#TilleggsopplysningPasient">Andre&#160;pasientopplysninger</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:TilknyttetEnhet">
						<li>
							<a href="#TilknyttetEnhet">Kontaktinformasjon&#160;virksomhet</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:KontaktpersonHelsepersonell">
						<li>
							<a href="#KontaktpersonHelsepersonell">Kontaktpersoner&#160;helsepersonell</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:AnsvarForRapport">
						<li>
							<a href="#AnsvarForRapport">Ansvar&#160;for&#160;rapport</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:SendtDokument">
						<li>
							<a href="#SendtDokument">Tilknyttet&#160;dokument</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:OpplysningerTilSoknad">
						<li>
							<a href="#OpplysningerTilSoknad">Opplysninger&#160;til&#160;søknad</a>
						</li>
					</xsl:if>
					<xsl:if test="//po:OpplysningerOmIndividuellPlan">
						<li>
							<a href="#OpplysningerOmIndividuellPlan">Opplysninger&#160;om&#160;individuell&#160;plan</a>
						</li>
					</xsl:if>
				</ul>
			</div>
		</div>
	</xsl:template>
	<!-- Visning av vedlagte dokument -->
	<xsl:template name="DokumentPLO">
		<!--Tabell og overskrift for aktuell problemstilling. NB! Hardkodet kodeverk. Hvis kodeverk 9142 endrer seg, må linjen under også endres. Bedre løsning?-->
		<xsl:if test="//epj2:GenereltJournalnotat[.//epj2:Overskriftskode[@V='PROB']]">
			<h2 id="Problemstilling">Aktuell problemstilling</h2>
			<table>
				<tbody>
					<xsl:for-each select="//epj2:GenereltJournalnotat[.//epj2:Overskriftskode[@V='PROB']]">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<xsl:if test="//epj2:GenereltJournalnotat[.//epj2:Overskriftskode[@V='FO']]">
			<h2 id="Forlop">Forløp og behandling</h2>
			<table>
				<tbody>
					<xsl:for-each select="//epj2:GenereltJournalnotat[.//epj2:Overskriftskode[@V='FO']]">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!-- Tabell og overskrift for Medisinske diagnoser. NB! Hardkodet kodeverk. Hvis kodeverk 9142 endrer seg, må linjen under også endres.-->
		<xsl:if test="//po:InfoMedisinskDiagnose or //epj2:GenereltJournalnotat[.//epj2:Overskriftskode[@V='TS']]">
			<xsl:if test="//po:InfoMedisinskDiagnose">
				<h2 id="InfoMedisinskDiagnose">Medisinske&#160;diagnoser</h2>
				<table>
					<tbody>
						<xsl:for-each select="//po:InfoMedisinskDiagnose">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<xsl:if test="//epj2:GenereltJournalnotat[.//epj2:Overskriftskode[@V='TS']]">
				<h2 id="Andre relevante tilstander">Andre relevante tilstander</h2>
				<table>
					<tbody>
						<xsl:for-each select="//epj2:GenereltJournalnotat[.//epj2:Overskriftskode[@V='TS']]">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
		</xsl:if>
		<!-- Tabell og overskrift for IPLOSrelevant informasjon -->
		<xsl:if test="//po:InfoIPLOSrelevantInformasjon">
			<h2 id="InfoIPLOSrelevantInformasjon">IPLOSrelevant&#160;informasjon</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:InfoIPLOSrelevantInformasjon">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!--Tabell og overskrift for helsefaglige opplysninger-->
		<!--<xsl:if test="//epj1:Cave or //po:InfoAndreViktigeOpplysninger or //epj2:GenereltJournalnotat[not(ancestor::po:InfoAndreViktigeOpplysninger)]">
			<h2 id="HelsefagligeOpplysninger">Helsefaglige&#160;opplysninger</h2>-->
		<!--Viktige opplysninger-->
		<xsl:if test="//epj1:Cave or //po:InfoAndreViktigeOpplysninger">
			<h2 id="ViktigeOpplysninger">Viktige&#160;opplysninger</h2>
			<table>
				<tbody>
					<xsl:for-each select="//epj1:Cave">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
					<xsl:for-each select="//po:InfoAndreViktigeOpplysninger">
						<xsl:apply-templates select="epj1:Allerginotat"/>
						<xsl:apply-templates select="epj2:GenereltJournalnotat"/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!--Andre generelle journalnotat-->
		<xsl:if test="//epj2:GenereltJournalnotat[not(ancestor::po:InfoAndreViktigeOpplysninger) and .//epj2:Overskriftskode[not(@V='TS' or @V='PROB' or @V='FO')]]">
			<h2 id="GenerelleJournalNotat">Generelle&#160;journalnotat</h2>
			<table>
				<tbody>
					<xsl:for-each select="//epj2:GenereltJournalnotat[not(ancestor::po:InfoAndreViktigeOpplysninger) and not(.//epj2:Overskriftskode[@V='TS' or @V='PROB'  or @V='FO'])]">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!--</xsl:if>	-->
		<!-- Tabell og overskrift for legemiddelopplysninger -->
		<xsl:if test="//po:Legemiddelhandtering">
			<h2 id="LegemiddelOpplysninger">Legemiddelopplysninger</h2>
			<!--Tabell og overskriftt for legemiddelhåndtering-->
			<xsl:if test="//po:Legemiddelhandtering">
				<h3>Legemiddelhåndtering</h3>
				<table>
					<tbody>
						<xsl:for-each select="//po:Legemiddelhandtering">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
		</xsl:if>
		<!-- Tabell og overskrift for OpplysningerRelevantOppfolging -->
		<xsl:if test="//po:OpplysningerRelevantOppfolging">
			<h2 id="OpplysningerRelevantOppfolging">Relevant oppfølging</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:OpplysningerRelevantOppfolging">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!-- Tabell og overskrift for Kartlegging av funksjonsnivå -->
		<xsl:if test="//po:InfoKartleggingFunksjonsniva">
			<h2 id="InfoKartleggingFunksjonsniva">Funksjonsbeskrivelse</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:InfoKartleggingFunksjonsniva">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!-- Tabell og overskrift for Hjelpemidler -->
		<xsl:if test="//po:OpplysningerOmHjelpemidler">
			<h2 id="OpplysningerOmHjelpemidler">Hjelpemidler</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:OpplysningerOmHjelpemidler">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!-- Tabell og overskrift for Kontrolltime -->
		<xsl:if test="//po:InfoKontrolltime">
			<h2 id="InfoKontrolltime">Kontrolltimer</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:InfoKontrolltime">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!-- Tabell og overskrift for Pasientlogistikk-meldingene -->
		<xsl:if test="//p1:OrienteringOmDod or //p1:MeldingOmUtskrevetPasient or //p1:MeldingUtskrivningsklarPasient or //p1:AvmeldingUtskrivningsklarPasient or //p1:MeldingInnlagtPasient or //p1:TilbakemeldingUtskrivningsklarPasient">
			<xsl:if test="//po:TidsfestetHendelse">
				<h2 id="TidsfestetHendelse">Tidsfestet&#160;hendelse</h2>
				<table>
					<tbody>
						<xsl:for-each select="//po:TidsfestetHendelse">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<xsl:if test="//po:UtskrevetTil">
				<h2 id="UtskrevetTil">Utskrevet&#160;til</h2>
				<table>
					<tbody>
						<xsl:for-each select="//po:UtskrevetTil">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
		</xsl:if>
		<!-- Tabell og overskrift for Opplysninger om opphold -->
		<xsl:if test="//po:OpplysningOpphold">
			<h2 id="OpplysningOpphold">Opplysninger&#160;om&#160;opphold/konsultasjon</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:OpplysningOpphold">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!-- Tabell og overskrift for Eksisterende tjenester -->
		<xsl:if test="//po:EksisterendeTjeneste">
			<h2 id="EksisterendeTjeneste">Eksisterende&#160;tjenester</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:EksisterendeTjeneste">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!-- Tabell og overskrift for Assistert kommunikasjon -->
		<!-- Tabell og overskrift for Andre pasientopplysninger -->
		<xsl:if test="//po:TilleggsopplysningPasient or //po:AssistertKommunikasjon or //po:ParorendeForesatt or //po:PasientrelatertKontaktperson">
			<h2 id="TilleggsopplysningPasient">Andre&#160;pasientopplysninger</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:TilleggsopplysningPasient">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
			<xsl:if test="//po:AssistertKommunikasjon">
				<h3>Assistert kommunikasjon</h3>
				<table>
					<tbody>
						<xsl:for-each select="//po:AssistertKommunikasjon">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<xsl:if test="//po:ParorendeForesatt">
				<h3>Pårørende/foresatt</h3>
				<table>
					<tbody>
						<xsl:for-each select="//po:ParorendeForesatt">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<xsl:if test="//po:PasientrelatertKontaktperson">
				<h3>Pasientrelaterte kontaktpersoner</h3>
				<table>
					<tbody>
						<xsl:for-each select="//po:PasientrelatertKontaktperson">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
		</xsl:if>
		<!-- Tabell og overskrift for Pårørende/foresatte -->
		<!--<xsl:if test="//po:ParorendeForesatt">
			<h2 id="ParorendeForesatt">Pårørende/foresatte</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:ParorendeForesatt">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>-->
		<!--Tabell og overskrift for pasientrelatert kontaktperson-->
		<!--<xsl:if test="//po:PasientrelatertKontaktperson">
			<h2 id="PasientrelatertKontaktperson">Pasientrelaterte kontaktpersoner</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:PasientrelatertKontaktperson">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>		-->
		<!-- Tabell og overskrift for Andre notater -->
		<!--	<xsl:if test="//mh:Content/epj2:Notater">
			<h2 id="AndreNotater">Andre notater</h2>
			<table>
				<tbody>
					<xsl:for-each select="//mh:Content/epj2:Notater">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>-->
		<!-- Tabell og overskrift for Kontaktinformasjon virksomhet -->
		<xsl:if test="//po:TilknyttetEnhet">
			<h2 id="TilknyttetEnhet">Kontaktinformasjon&#160;virksomhet</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:TilknyttetEnhet">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!-- Tabell og overskrift for Kontaktpersoner helsepersonell -->
		<xsl:if test="//po:KontaktpersonHelsepersonell">
			<h2 id="KontaktpersonHelsepersonell">Kontaktpersoner&#160;helsepersonell</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:KontaktpersonHelsepersonell">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!-- Tabell og overskrift for Ansvar for rapport -->
		<xsl:if test="//po:AnsvarForRapport">
			<h2 id="AnsvarForRapport">Ansvar&#160;for&#160;rapport</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:AnsvarForRapport">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!-- Tabell og overskrift for Sendt dokument -->
		<xsl:if test="//po:SendtDokument">
			<h2 id="SendtDokument">Tilknyttet&#160;dokument</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:SendtDokument">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!-- Tabell og overskrift for Opplysninger til søknad -->
		<xsl:if test="//po:OpplysningerTilSoknad">
			<h2 id="OpplysningerTilSoknad">Opplysninger&#160;til&#160;søknad</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:OpplysningerTilSoknad">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
		<!--Tabell og overskrift for opplysninger om individuell plan-->
		<xsl:if test="//po:OpplysningerOmIndividuellPlan">
			<h2 id="OpplysningerOmIndividuellPlan">Opplysinger&#160;om&#160;individuell&#160;plan</h2>
			<table>
				<tbody>
					<xsl:for-each select="//po:OpplysningerOmIndividuellPlan">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!--Overskrift og innhold for vedlagt m25 dokument. Forutsetter at det er lagt inn som et nytt <Document> element på samme nivå som forekomsten av "PLO-<Document>". -->
	<xsl:template name="m25vedlegg">
		<!--<div class="{$stil}">
			<xsl:for-each select="//mh:Document/mh:RefDoc/mh:Content[m25:LegemidlerIBruk]">
				<h1>M25 vedlegg</h1>
				--><!--Innhold template fra importert M25 visningsfil--><!--
				<xsl:call-template name="Innhold"/>			
			</xsl:for-each>
		</div>-->
	</xsl:template>
</xsl:stylesheet>

