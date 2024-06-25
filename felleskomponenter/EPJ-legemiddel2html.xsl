<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epj3="http://www.kith.no/xmlstds/epj/epj3/2008-02-20" xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" exclude-result-prefixes="epj3 fk1">
	
	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
	
	<xsl:template match="epj3:Legemidler">
		<div class="epj3:Legemidler">
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	<xsl:template match="epj3:Legemiddelinfo">
		<xsl:apply-templates select="epj3:Legemiddelinfo">
			<xsl:sort select="epj3:ForenkletForskrivning/epj3:Forskrivningsinfo/epj3:Bruk/@V" order="descending"/>
		</xsl:apply-templates>
		<xsl:if test="not(preceding-sibling::epj3:Legemiddelinfo)">
			<h2 id="Legemiddelinfo">Legemidler</h2>
		</xsl:if>
		<div class="epj3:Legemiddelinfo">
			<table width="100%">
				<xsl:if test="not(preceding-sibling::epj3:Legemiddelinfo)">
					<tr>
						<th width="10%">Start</th>
						<th width="10%">Sep.</th>
						<th width="10%">Navn</th>
						<th width="8%">Form</th>
						<th width="5%">Styrke</th>
						<th width="10%">Forordning</th>
						<th width="17%">Dosering</th>
						<th width="30%">Merknad</th>
					</tr>
				</xsl:if>
				<xsl:apply-templates select="epj3:ForenkletForskrivning"/>
			</table>
		</div>
	</xsl:template>
	<xsl:template match="epj3:ForenkletForskrivning">
		<!--<div class="epj3:ForenkletForskrivning">-->
		<xsl:choose>
			<xsl:when test="epj3:StatusTilForskrivningen/@V='2'">
				<tr>
					<th style="background-color:#ffff00" colspan="9">
						<b>
							<xsl:choose>
								<xsl:when test="epj3:StatusTilForskrivningen/@DN">
									<xsl:choose>
										<xsl:when test="epj3:StatusTilForskrivningen/@V='2'">Seponert</xsl:when>
										<xsl:otherwise><xsl:value-of select="epj3:StatusTilForskrivningen/@DN"/></xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>Forskrivning</xsl:otherwise>
							</xsl:choose>
						</b>
					</th>
				</tr>
			</xsl:when>
		</xsl:choose>
		<tr>
			<td width="10%">
				<!-- ***  Sjekker om kun dato er oppgitt (strengen = 10 tegn)  *** -->
				<xsl:if test="string-length(epj3:Forskrivningsinfo/epj3:DoseringStarttidspunkt/@V)='10'">
					<xsl:value-of select="epj3:Forskrivningsinfo/epj3:DoseringStarttidspunkt/@V"/>
				</xsl:if>
				<!-- ***  Sjekker om kun klokkeslett er oppgitt (strengen = 8 tegn)  *** -->
				<xsl:if test="string-length(epj3:Forskrivningsinfo/epj3:DoseringStarttidspunkt/@V)='8'">
					<xsl:value-of select="substring(epj3:Forskrivningsinfo/epj3:DoseringStarttidspunkt/@V,1,5)"/>
				</xsl:if>
				<!-- ***  Sjekker om både dato og klokkeslett er oppgitt (strengen > 10 tegn), skriver kun ut dato  *** -->
				<xsl:if test="string-length(epj3:Forskrivningsinfo/epj3:DoseringStarttidspunkt/@V) &gt;10">
					<xsl:value-of select="substring(epj3:Forskrivningsinfo/epj3:DoseringStarttidspunkt/@V,1,10)"/>
				</xsl:if>				 				 
			</td>
			<td width="10%">
				<!-- ***  Sjekker om kun dato er oppgitt (strengen = 10 tegn)  *** -->
				<xsl:if test="string-length(epj3:Forskrivningsinfo/epj3:DoseringSluttidspunkt/@V)='10'">
					<xsl:value-of select="epj3:Forskrivningsinfo/epj3:DoseringSluttidspunkt/@V"/>
				</xsl:if>
				<!-- ***  Sjekker om kun klokkeslett er oppgitt (strengen = 8 tegn)  *** -->
				<xsl:if test="string-length(epj3:Forskrivningsinfo/epj3:DoseringSluttidspunkt/@V)='8'">
					<xsl:value-of select="substring(epj3:Forskrivningsinfo/epj3:DoseringSluttidspunkt/@V,1,5)"/>
				</xsl:if>
				<!-- ***  Sjekker om både dato og klokkeslett er oppgitt (strengen > 10 tegn), skriver kun ut dato  *** -->
				<xsl:if test="string-length(epj3:Forskrivningsinfo/epj3:DoseringSluttidspunkt/@V) &gt;10">
					<xsl:value-of select="substring(epj3:Forskrivningsinfo/epj3:DoseringSluttidspunkt/@V,1,10)"/>
				</xsl:if>			
			</td>
			<td width="10%">
				<xsl:value-of select="epj3:Forskrivningsinfo/epj3:Navn"/>
				<xsl:if test="epj3:Forskrivningsinfo/epj3:GeneriskNavn">&#160;(<xsl:value-of select="epj3:Forskrivningsinfo/epj3:GeneriskNavn"/>)</xsl:if>
			</td>
			<td width="8%">
				<xsl:value-of select="epj3:Forskrivningsinfo/epj3:Legemiddelform/@DN"/>
			</td>
			<td width="5%">
				<xsl:value-of select="epj3:Forskrivningsinfo/epj3:Styrke/@V"/>&#160;
				<xsl:value-of select="epj3:Forskrivningsinfo/epj3:Styrke/@U"/>
			</td>
			<td width="10%">
				<xsl:value-of select="epj3:Forskrivningsinfo/epj3:Bruk/@DN"/>
			</td>
			<td width="17%">
				<xsl:value-of select="epj3:Forskrivningsinfo/epj3:DosVeiledEnkel"/>
			</td>
			<td width="30%">
				<xsl:value-of select="epj3:Merknad"/><br/> 
				<xsl:if test="epj3:InngaarIMultidose/@V=2">Multidose<br/></xsl:if>
				<xsl:if test="epj3:Forskrivningsinfo/epj3:SkalIkkeTasSammenMedAnnetLegemiddel = 'true' or epj3:Forskrivningsinfo/epj3:SkalIkkeTasSammenMedAnnetLegemiddel = '1'">Skal ikke tas sammen med annet legemiddel.<br/></xsl:if>
				<xsl:if test="epj3:Forskrivningsinfo/epj3:BruksomradeTekst"><xsl:value-of select="epj3:Forskrivningsinfo/epj3:BruksomradeTekst"/><br/></xsl:if>	
			</td>
		</tr>
		<xsl:for-each select="epj3:Forskriver">
			<tr>
				<td colspan="8">Forskriver:&#160;
								<xsl:if test="fk1:TypeHealthcareProfessional">
						<xsl:value-of select="fk1:TypeHealthcareProfessional/@DN"/>&#160;</xsl:if>
					<xsl:value-of select="fk1:GivenName"/>&#160;<xsl:if test="fk1:MiddleName">
						<xsl:value-of select="fk1:MiddleName"/>&#160;</xsl:if>
					<xsl:if test="fk1:FamilyName">
						<xsl:value-of select="fk1:FamilyName"/>&#160;</xsl:if>
					<xsl:if test="fk1:RoleToPatient">(<xsl:value-of select="fk1:RoleToPatient"/>)&#160;</xsl:if>
					<xsl:for-each select="fk1:Ident[fk1:TypeId/@V='HPR']">HPR-nummer: <xsl:value-of select="fk1:Id"/>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:for-each>
		<!--</div>-->
	</xsl:template>
	<xsl:template match="epj3:LegemidlerAdministrertVedOverforing">
		<div class="epj3:LegemidlerAdministrertVedOverforing">
				<xsl:apply-templates select="epj3:AdmAvHelsepersonell"/>
				<xsl:apply-templates select="epj3:Egenadministrering"/>
		</div>
	</xsl:template>
	<xsl:template match="epj3:AdmAvHelsepersonell">
		<div class="epj3:AdmAvHelsepersonell">
			<xsl:if test="not(preceding-sibling::epj3:AdmAvHelsepersonell)">
				<h3>Legemidler administrert av helsepersonell på utskrivningsdag</h3>
			</xsl:if>
			<table width="100%">
				<tbody>
					<xsl:if test="not(preceding-sibling::epj3:AdmAvHelsepersonell)">
						<tr>
							<th width="10%">Tidspunkt</th>
							<th width="15%">Navn</th>
							<th width="10%">Form</th>
							<th width="8%">Styrke</th>
							<th width="25%">Veil. til dosering</th>
							<th width="32%">Merknad</th>
						</tr>
					</xsl:if>		
					<tr>
						<td width="10%">
							<!-- ***  Sjekker om kun dato er oppgitt (strengen = 10 tegn)  *** -->
							<xsl:if test="string-length(epj3:AdmStart/@V)='10'">
								<xsl:value-of select="epj3:AdmStart/@V"/>
							</xsl:if>
							<!-- ***  Sjekker om kun klokkeslett er oppgitt (strengen = 8 tegn)  *** -->
							<xsl:if test="string-length(epj3:AdmStart/@V)='8'">
								<xsl:value-of select="epj3:AdmStart/@V"/>
							</xsl:if>
							<!-- ***  Sjekker om både dato og klokkeslett er oppgitt (strengen > 10 tegn), skriver kun ut klokkeslett *** -->
							<xsl:if test="string-length(epj3:AdmStart/@V) &gt;10">
								<xsl:value-of select="substring(epj3:AdmStart/@V,12,5)"/>
							</xsl:if>						
						</td>					
						<td width="15%">
							<xsl:value-of select="epj3:Forskrivningsinfo/epj3:Navn"/>
							<xsl:if test="epj3:Forskrivningsinfo/epj3:GeneriskNavn">&#160;(<xsl:value-of select="epj3:Forskrivningsinfo/epj3:GeneriskNavn"/>)</xsl:if>
						</td>
						<td width="10%">
							<xsl:value-of select="epj3:Forskrivningsinfo/epj3:Legemiddelform/@DN"/>
						</td>
						<td width="8%">
							<xsl:value-of select="epj3:Forskrivningsinfo/epj3:Styrke/@V"/>&#160;
							<xsl:value-of select="epj3:Forskrivningsinfo/epj3:Styrke/@U"/>
						</td>
						<td width="25%">
							<xsl:value-of select="epj3:Forskrivningsinfo/epj3:DosVeiledEnkel"/>
						</td>
						<td width="32%">
							<xsl:if test="epj3:Forskrivningsinfo/epj3:SkalIkkeTasSammenMedAnnetLegemiddel = 'true' or epj3:Forskrivningsinfo/epj3:SkalIkkeTasSammenMedAnnetLegemiddel = '1'">&#160;Skal ikke tas sammen med annet legemiddel.<br/>
							</xsl:if>
							<xsl:if test="epj3:AdmEnkeltdose">Enkeltdose: <xsl:value-of select="epj3:AdmEnkeltdose/@V"/>&#160;<xsl:value-of select="epj3:AdmEnkeltdose/@U"/>
								<br/>
							</xsl:if>
							<xsl:if test="epj3:AdmStatus">Adm status: <xsl:value-of select="epj3:AdmStatus/@DN"/><br/>
							</xsl:if>
							<xsl:if test="epj3:AdministrertLegemiddel/epj3:Kvantum">Kvantum: <xsl:value-of select="epj3:AdministrertLegemiddel/epj3:Kvantum"/><br/>
							</xsl:if>
							<xsl:if test="epj3:Forskrivningsinfo/epj3:BruksomradeTekst"><xsl:value-of select="epj3:Forskrivningsinfo/epj3:BruksomradeTekst"/>
							</xsl:if>							
						</td>
					</tr>
					<xsl:for-each select="epj3:AdministrertAv">
						<tr>
							<td colspan="8">Administrert av:&#160;
								<xsl:if test="fk1:TypeHealthcareProfessional">
									<xsl:value-of select="fk1:TypeHealthcareProfessional/@DN"/>&#160;</xsl:if>
								<xsl:value-of select="fk1:GivenName"/>&#160;<xsl:if test="fk1:MiddleName">
									<xsl:value-of select="fk1:MiddleName"/>&#160;</xsl:if>
								<xsl:if test="fk1:FamilyName">
									<xsl:value-of select="fk1:FamilyName"/>&#160;</xsl:if>
								<xsl:if test="fk1:RoleToPatient">(<xsl:value-of select="fk1:RoleToPatient"/>)&#160;</xsl:if>
								<xsl:for-each select="fk1:Ident[fk1:TypeId/@V='HPR']">HPR-nummer: <xsl:value-of select="fk1:Id"/>
								</xsl:for-each>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</div>
	</xsl:template>
	<xsl:template match="epj3:Egenadministrering">
		<div class="epj3:Egenadministrering">
			<xsl:if test="not(preceding-sibling::epj3:Egenadministrering)">
				<h3>Legemidler adminstrert av pasient/pårørende på utskrivningsdag</h3>
			</xsl:if>
			<table width="100%">
				<tbody>
					<xsl:if test="not(preceding-sibling::epj3:Egenadministrering)">
						<tr>
							<th width="10%">Tidspunkt</th>
							<th width="15%">Navn</th>
							<th width="10%">Form</th>
							<th width="8%">Styrke</th>
							<th width="25%">Veil. til dosering</th>
							<th width="32%">Merknad</th>
						</tr>
					</xsl:if>
					<tr>
						<td width="10%">
							<!-- ***  Sjekker om kun dato er oppgitt (strengen = 10 tegn)  *** -->
							<xsl:if test="string-length(epj3:AdmStart/@V)='10'">
								<xsl:value-of select="epj3:AdmStart/@V"/>
							</xsl:if>
							<!-- ***  Sjekker om kun klokkeslett er oppgitt (strengen = 8 tegn)  *** -->
							<xsl:if test="string-length(epj3:AdmStart/@V)='8'">
								<xsl:value-of select="epj3:AdmStart/@V"/>
							</xsl:if>
							<!-- ***  Sjekker om både dato og klokkeslett er oppgitt (strengen > 10 tegn), skriver kun ut klokkeslett *** -->
							<xsl:if test="string-length(epj3:AdmStart/@V) &gt;10">
								<xsl:value-of select="substring(epj3:AdmStart/@V,12,5)"/>
							</xsl:if>						
						</td>		
						<td width="15%">
							<xsl:value-of select="epj3:Forskrivningsinfo/epj3:Navn"/>
							<xsl:if test="epj3:Forskrivningsinfo/epj3:GeneriskNavn">&#160;(<xsl:value-of select="epj3:Forskrivningsinfo/epj3:GeneriskNavn"/>)</xsl:if>
						</td>
						<td width="10%">
							<xsl:value-of select="epj3:Forskrivningsinfo/epj3:Legemiddelform/@DN"/>
						</td>
						<td width="8%">
							<xsl:value-of select="epj3:Forskrivningsinfo/epj3:Styrke/@V"/>&#160;
							<xsl:value-of select="epj3:Forskrivningsinfo/epj3:Styrke/@U"/>
						</td>
						<td width="25%">
							<xsl:value-of select="epj3:Forskrivningsinfo/epj3:DosVeiledEnkel"/>
						</td>
						<td width="32%">
							<xsl:if test="epj3:Forskrivningsinfo/epj3:SkalIkkeTasSammenMedAnnetLegemiddel = 'true' or epj3:Forskrivningsinfo/epj3:SkalIkkeTasSammenMedAnnetLegemiddel = '1'">&#160;Skal ikke tas sammen med annet legemiddel.<br/>
							</xsl:if>
							<xsl:if test="epj3:AdmEnkeltdose">Enkeltdose: <xsl:value-of select="epj3:AdmEnkeltdose/@V"/>&#160;<xsl:value-of select="epj3:AdmEnkeltdose/@U"/>
								<br/>
							</xsl:if>
							<xsl:if test="epj3:AdmStatus">Adm status: <xsl:value-of select="epj3:AdmStatus/@DN"/>
								<br/>
							</xsl:if>
							<xsl:if test="epj3:UtlevertLegemiddel/epj3:AntEnkeltdoser">Antall enkeltdoser utlevert: <xsl:value-of select="epj3:UtlevertLegemiddel/epj3:AntEnkeltdoser"/><br/></xsl:if>
							<xsl:if test="epj3:Forskrivningsinfo/epj3:BruksomradeTekst"><xsl:value-of select="epj3:Forskrivningsinfo/epj3:BruksomradeTekst"/>
							</xsl:if>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</xsl:template>
</xsl:stylesheet>
