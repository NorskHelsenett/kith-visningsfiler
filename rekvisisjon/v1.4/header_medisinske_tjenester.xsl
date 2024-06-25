<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:hmt="http://www.kith.no/xmlstds/medtjenhdr/2008-23-05" 
	xmlns:lso="http://www.kith.no/xmlstds/rekvisisjon/2005-05-20" 
	xmlns="http://www.w3.org/1999/xhtml" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	exclude-result-prefixes="hmt lso xhtml">

<!--
FORMÅL
Felles XSLT for generering av html for visningsfiler for diverse svarrapporter av Medisinske Tjenester - v1.0

ENDRINGER:
29.09.2008 
	Sjekket på om det finnes @DN=Fødselsnummer på OffId ellers @V= FNR
	Lagt til ReqComMethod
-->

	<!-- Meldingshodet - avsender og mottaker-informasjon -->
	<xsl:template name="Header">
		<div class="Header">
			<div class="Patient">
				<b>Pasient:</b>
				<br/>
				<xsl:apply-templates select="lso:Patient"/>
			</div>
			<div class="ServProvider">
				<b>Tjenesteyter:</b>
				<br/>
				<xsl:apply-templates select="lso:ServProvider"/>
				<xsl:apply-templates select="lso:RelServProv"/>
			</div>
			<div class="Requester">
				<b>Rekvirent:</b>
				<br/>
				<xsl:apply-templates select="lso:Requester"/>
			</div>
			<div class="CopyDest">
				<b>Kopimottaker(e)</b>
				<br/>
				<xsl:apply-templates select="lso:CopyDest"/>
			</div>
		</div>
	</xsl:template>
	
	
	<xsl:template match="lso:Patient">
		<b>Navn:&#160;</b>
		<xsl:value-of select="lso:Name"/>
		<br/>
		<xsl:if test="lso:OffId">
			
			<xsl:choose>
				<xsl:when test="lso:OffId/@DN">
					<b><xsl:value-of select="lso:TypeOffId/@DN"/> :&#160;</b>
				</xsl:when>
				<xsl:otherwise><b><xsl:value-of select="lso:TypeOffId/@V"/> :&#160;</b></xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="lso:OffId"/>

		</xsl:if>
		<br/>
		<xsl:if test="lso:Address">
			<xsl:apply-templates select="lso:Address"/>
		</xsl:if>
	</xsl:template>



	<xsl:template match="lso:Address">
		<xsl:if test="lso:Type">
			<b>
				<xsl:value-of select="lso:Type/@DN"/>:</b>
		</xsl:if>
		<xsl:if test="lso:StreetAdr">
			<xsl:value-of select="lso:StreetAdr"/>
			<br/>
		</xsl:if>
		<xsl:if test="lso:PostalCode">
			<b>Poststed:</b>
			<xsl:value-of select="lso:PostalCode"/>&#xA0;</xsl:if>
		<xsl:if test="lso:City">
			<xsl:value-of select="lso:City"/>
			<br/>
		</xsl:if>
		<xsl:if test="lso:County">
			<xsl:value-of select="lso:County/@DN"/>
			<br/>
		</xsl:if>
		<xsl:if test="lso:Country">
			<xsl:value-of select="lso:Country/@DN"/>
			<br/>
		</xsl:if>
		<br/>
	</xsl:template>

	<xsl:template match="lso:ServProvider">
		<!-- utelater rolle <Role>, da denne kun er "Tjenesteyter" -->
		<xsl:apply-templates select="lso:HCP"/>
	</xsl:template>
	
	
	<xsl:template match="lso:RelServProv">
		<xsl:value-of select="lso:Relation/@DN"/>:&#160;<xsl:apply-templates select="lso:HCP"/>
	</xsl:template>


	<xsl:template match="lso:CopyDest">
		<!-- utelatt rolle-->
		<xsl:apply-templates select="lso:CopyDestRole"/>
		<xsl:apply-templates select="lso:HCP"/>
	</xsl:template>
	<xsl:template match="lso:CopyDestRole">
		<xsl:value-of select="lso:MsgType/@DN"/>
		<xsl:choose>	
			<xsl:when test="lso:ReqComMethod">&#160;foreslås pr.&#160;<xsl:value-of select="lso:ReqComMethod/@DN"/></xsl:when>
			<xsl:when test="lso:ActComMethod">&#160;pr.&#160;<xsl:value-of select="lso:ActComMethod/@DN"/></xsl:when>
		</xsl:choose>
		&#160;til&#160;<br/>
	</xsl:template>

	<xsl:template match="lso:HCP">
		<xsl:apply-templates select="lso:Inst"/>
		<xsl:apply-templates select="lso:HCProf"/>
		<xsl:apply-templates select="MedSpeciality"/>
		<xsl:apply-templates select="lso:Adress"/>
	</xsl:template>

	<xsl:template match="lso:Inst">
		<xsl:value-of select="lso:Name"/>
		<br/>
		<xsl:apply-templates select="Id"/>
		<br/>
		<xsl:apply-templates select="TypeId"/>
		<br/>
		<xsl:for-each select="lso:Dept">Avdeling: <xsl:value-of select="lso:Name"/>&#160;<br/>
		Avdelingsnr(lokal): <xsl:value-of select="lso:Id"/>
			<br/>
		</xsl:for-each>
		<xsl:apply-templates select="lso:HCPerson"/>
		<xsl:apply-templates select="lso:AdditionalId"/>
	</xsl:template>

	<xsl:template match="lso:HCPerson">
		<xsl:value-of select="lso:Name"/>
		<xsl:if test="lso:Id">&#160;-&#160;<xsl:value-of select="lso:TypeId/@V"/>:<xsl:value-of select="lso:Id"/>
		</xsl:if>
		<br/>
		<xsl:if test="lso:AdditionalId">
			<xsl:value-of select="lso:AdditionalId/lso:Type/@V"/>:<xsl:value-of select="lso:AdditionalId/lso:Id"/>
		</xsl:if>
		<br/>
	</xsl:template>

	<xsl:template match="lso:HCProf">
		<xsl:if test="lso:Type">
			<xsl:value-of select="lso:Type/@DN"/>&#160;</xsl:if>
		<xsl:value-of select="lso:Name"/>
		<xsl:if test="lso:Id">&#160;-&#160;<xsl:value-of select="lso:TypeId/@V"/>:<xsl:value-of select="lso:Id"/>
		</xsl:if>
		<br/>
	</xsl:template>
	<!--Slutt på meldingshodet -->

	
	</xsl:stylesheet>
