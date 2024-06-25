<?xml version="1.0" encoding="utf-8"?>
<!--	Visningsfil for Innrapportering av vederlagstrekk til NAV
	04.06.2021: v3.1.4: Lagt til xsl:output for å definere at output formatet skal være html
	20.06.2017: v3.1.3: Erstattet hairspace med puncspace som mellomromtegn.
	09.05.2017: v3.1.2: Rettet feil sti for importfil.
	27.03.2017: v3.1.1: Ny parameter for "visningStil. Ny stil "Smooth".
	25.10.2016: v3.1.0: La til variabel for visningsversjonnr
	30.10.2010: Første versjon
-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:ivt="http://www.kith.no/xmlstds/nav/innrapporteringtrekk/2010-02-04" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	exclude-result-prefixes="fk1 ivt mh xhtml">


	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<xsl:include href="../hodemelding/v1.2/Hodemelding2html.xsl"/>

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'trekk1.0 - v3.1.4'"/>


	<xsl:template match="/">
		<html>
			<head>
				<title>Innrapportering av vederlagstrekk</title>
				<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/KITH-visning.css')" disable-output-escaping="yes"/>
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/smooth-visning.css')" disable-output-escaping="yes"/>
				</style>
			</head>
			<body>
				<xsl:apply-templates/>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="ivt:InnrapporteringTrekk">
		<main class="{$stil}">
			<h1>
				<xsl:if test="//mh:MsgInfo/mh:Type/@V='INNRAPPORTERING_TREKK_RETUR'">Retur&#160;-&#160;</xsl:if>Innrapportering av vederlagstrekk<xsl:apply-templates select="ivt:Aksjonskode"/>
			</h1>
			<xsl:apply-templates select="ivt:Identifisering"/>
			<xsl:apply-templates select="ivt:Trekk"/>
			<xsl:apply-templates select="ivt:Periode"/>
			<xsl:apply-templates select="ivt:Kreditor"/>
		</main>
	</xsl:template>

	<xsl:template match="ivt:Identifisering">
		<h3>Identifisering</h3>
		<div class="Box">
			<div class="Block">
				<div class="MainCaption">Kreditors trekk-ID</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:KreditorTrekkId"/>&#8200;
				</div>
			</div>
			<div class="Block">
				<div class="MainCaption">NAVs trekk-ID</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:NavTrekkId"/>&#8200;
				</div>
			</div>
			<div class="Block">
				<div class="MainCaption">Debitors ID (<xsl:value-of select="ivt:DebitorId/fk1:TypeId/@V"/>)</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:DebitorId/fk1:Id"/>&#8200;
				</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="ivt:Trekk">
		<h3>Trekk</h3>
		<div class="Box">
			<div class="Block">
				<div class="MainCaption">Kode trekktype</div>
				<div class="MainContent">
					<xsl:apply-templates select="ivt:KodeTrekktype"/>&#8200;
				</div>
			</div>
			<div class="Block" style="float: none; overflow: hidden; width: auto;">
				<div class="MainCaption">Kode trekk alternativ</div>
				<div class="MainContent">
					<xsl:apply-templates select="ivt:KodeTrekkAlternativ"/>&#8200;
				</div>
			</div>
			<div class="Block">
				<div class="MainCaption">Sats (<xsl:value-of select="ivt:Sats/@U"/>)</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:Sats/@V"/>&#8200;
				</div>
			</div>
			<div class="Block">
				<div class="MainCaption">Saldo (<xsl:value-of select="ivt:Saldo/@U"/>)</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:Saldo/@V"/>&#8200;
				</div>
			</div>
			<div class="Block">
				<div class="MainCaption">Gyldig t.o.m. dato</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:GyldigTomDato"/>&#8200;
				</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="ivt:Periode">
		<h3>Periode</h3>
		<div class="Box">
			<div class="Block">
				<div class="MainCaption">Periode f.o.m. dato</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:PeriodeFomDato"/>&#8200;
				</div>
			</div>
			<div class="Block">
				<div class="MainCaption">Periode t.o.m. dato</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:PeriodeTomDato"/>&#8200;
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="ivt:Kreditor">
		<h3>Kreditor</h3>
		<div class="Box">
			<div class="Block">
				<div class="MainCaption">ID TSS</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:TSSId"/>&#8200;
				</div>
			</div>
			<div class="Block">
				<div class="MainCaption">Organisasjonsnr. (<xsl:value-of select="ivt:OrgNr/fk1:TypeId/@V"/>)</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:OrgNr/fk1:Id"/>&#8200;
				</div>
			</div>
			<div class="Block" style="float: none; overflow: hidden;">
				<div class="MainCaption">Navn</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:Navn"/>&#8200;
				</div>
			</div>
			<div class="Block" >
				<div class="MainCaption">Adresse</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:Adresse/fk1:StreetAdr"/>
					<xsl:if test="ivt:Adresse/fk1:StreetAdr">,&#160;</xsl:if>
					<xsl:value-of select="ivt:Adresse/fk1:PostalCode"/>&#160;<xsl:value-of select="ivt:Adresse/fk1:City"/>
				</div>
			</div>
			<div class="Block">
				<div class="MainCaption">Referanse</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:Ref"/>&#8200;
				</div>
			</div>
			<div class="Block" style="float: none; overflow: hidden;">
				<div class="MainCaption">Kontonr.</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:Kontonr"/>&#8200;
				</div>
			</div>
			<div class="Block" style="clear: both;">
				<div class="MainCaption">KID</div>
				<div class="MainContent">
					<xsl:value-of select="ivt:KID"/>&#8200;
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- Kodeverk -->
	<xsl:template match="ivt:Aksjonskode">&#160;-&#160;
		<xsl:choose>
			<xsl:when test="@V='NY'">Nytt trekk</xsl:when>
			<xsl:when test="@V='ENDR'">Endring</xsl:when>
			<xsl:when test="@V='KANS'">Kreditor trekk</xsl:when>
			<xsl:when test="@V='OPPH'">Opphør</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="ivt:KodeTrekktype">
		<xsl:choose>
			<xsl:when test="@V='VEDE'">Vederlagstrekk</xsl:when>
			<xsl:when test="@V='FAGF'">Fagforeningstrekk</xsl:when>
			<xsl:when test="@V='KRED'">Kansellering av perioder</xsl:when>
			<xsl:when test="@V='PSKT'">Påleggstrekk skatt</xsl:when>
			<xsl:when test="@V='RSOS'">Refusjonskrav fra sosialkontor</xsl:when>
			<xsl:when test="@V='BSKT'">Kreditor disponerer</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="ivt:KodeTrekkAlternativ">
		<xsl:choose>
			<xsl:when test="@V='SALP'">Saldotrekk som trekker oppgitt prosent av ytelsen</xsl:when>
			<xsl:when test="@V='SALD'">Saldotrekk dagsats, beregnes ihht ytelses perioden</xsl:when>
			<xsl:when test="@V='SALM'">Saldotrekk månedsats</xsl:when>
			<xsl:when test="@V='LOPP'">Løpende trekk som trekker oppgitt prosent av ytelsen</xsl:when>
			<xsl:when test="@V='LOPD'">Løpende dagsats, beregnes ihht ytelses perioden</xsl:when>
			<xsl:when test="@V='LOPM'">Løpende månedsats</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>

