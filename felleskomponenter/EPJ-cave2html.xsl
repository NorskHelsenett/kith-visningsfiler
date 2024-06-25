<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epj1="http://www.kith.no/xmlstds/epj/epj1/2008-02-20" xmlns:epj2="http://www.kith.no/xmlstds/epj/epj2/2008-02-20" exclude-result-prefixes="epj1 epj2">
	
	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
	
	<xsl:include href="EPJ-journalnotat2html.xsl"/>
	
	<xsl:template match="epj1:Cave">
		<div class="epj1:Cave" id="Cave">
			<!--<h3>Cave</h3>-->
			<xsl:if test="not((preceding-sibling::epj1:Cave) and not(preceding-sibling::epj1:Allerginotat))">
			<br/>
			</xsl:if>
			<table width="100%" border="0">
				<tbody>
					<xsl:for-each select="epj1:SakshodeCave">
						<xsl:for-each select="epj1:StikkordCave">
							<tr>
								<td width="20%">
									<b>Cave</b>
								</td>
								<td width="80%" colspan="4">
									<xsl:value-of select="epj1:CaveStikkord"/>
									<xsl:if test="epj2:Journaltekst">
										<br/>
										<xsl:value-of select="epj2:Journaltekst/epj2:Notat"/>
									</xsl:if>
								</td>
							</tr>
						</xsl:for-each>
					</xsl:for-each>
					<xsl:for-each select="epj1:Allerginotat">
						<xsl:for-each select="epj1:Allergi">
							<tr>
								<td width="20%">
									<b>Allergisk mot:</b>
								</td>
								<td width="80%" colspan="4">
									<xsl:value-of select="epj1:AllergiskMot"/>
								</td>
							</tr>
							<tr>
								<td width="20%"/>
								<td width="20%">Hensyn ved forskrivning:&#160;<xsl:if test="epj1:HensynVedForskrivning = 'true' or epj1:HensynVedForskrivning = '1'">
										<b>Ja</b>
									</xsl:if>
									<xsl:if test="epj1:HensynVedForskrivning = 'false' or epj1:HensynVedForskrivning = '0'">Nei</xsl:if>
								</td>
								<td width="20%">Hensyn til mat og drikke:&#160;<xsl:if test="epj1:HensynMatDrikke = 'true' or epj1:HensynMatDrikke = '1'">
										<b>Ja</b>
									</xsl:if>
									<xsl:if test="epj1:HensynMatDrikke = 'false' or epj1:HensynMatDrikke = '0'">Nei</xsl:if>
								</td>
								<!--<th width="20%">Kontaktallergi</th>-->
								<td width="20%">Kontaktallergi:&#160;<xsl:if test="epj1:Kontaktallergi = 'true' or epj1:Kontaktallergi = '1'">
										<b>Ja</b>
									</xsl:if>
									<xsl:if test="epj1:Kontaktallergi = 'false' or epj1:Kontaktallergi = '0'">Nei</xsl:if>
								</td>
								<td width="20%">Pollen/innsektsstikk:&#160;<xsl:if test="epj1:PollenInnsektstikk = 'true' or epj1:PollenInnsektstikk = '1'">
										<b>Ja</b>
									</xsl:if>
									<xsl:if test="epj1:PollenInnsektstikk = 'false' or epj1:PollenInnsektstikk = '0'">Nei</xsl:if>
								</td>
							</tr>
							<xsl:if test="epj1:VirkestoffLegemiddel or epj1:KodeAnnetStoff or epj1:AnafylaktiskeRekasjoner">
								<tr>
									<td width="20%"/>
									<xsl:if test="epj1:VirkestoffLegemiddel">
										<td width="25%">Virkestoff i legemiddel:&#160;<xsl:value-of select="epj1:VirkestoffLegemiddel/@DN"/>
										</td>
									</xsl:if>
									<xsl:if test="epj1:KodeAnnetStoff">
										<td width="25%">Kode for annet stoff:&#160;<xsl:value-of select="epj1:KodeAnnetStoff/@DN"/>
										</td>
									</xsl:if>
									<xsl:if test="epj1:AnafylaktiskeRekasjoner">
										<td width="30%">Anafylaktiske reaksjoner:&#160;<xsl:value-of select="epj1:AnafylaktiskeRekasjoner/@DN"/>
										</td>
									</xsl:if>
								</tr>
							</xsl:if>
							<!--<tr>
								<th width="12.5%">Allergisk mot</th>
								<th width="12.5%">Anafylaktiske reaksjoner</th>
								<th width="12.5%">Hensyn ved forskrivning</th>
								<th width="12.5%">Hensyn mat/drikke</th>
								<th width="12.5%">Kontaktallergi</th>
								<th width="12.5%">Pollen/innsektstikk</th>
								<th width="12.5%">Virkestoff i legemiddel</th>
								<th width="12.5%">Kode for annet stoff</th>
							</tr>
							<tr>
								<td>
									<xsl:value-of select="epj1:AllergiskMot"/>
								</td>
								<td>
									<xsl:choose>
										<xsl:when test="epj1:AnafylaktiskeRekasjoner">
											<xsl:value-of select="epj1:AnafylaktiskeRekasjoner/@DN"/>
										</xsl:when>
										<xsl:otherwise>Ikke oppgitt</xsl:otherwise>
									</xsl:choose>
								</td>
								<td>
									<xsl:if test="epj1:HensynVedForskrivning = 'true' or epj1:HensynVedForskrivning = '1'">Ja</xsl:if>
									<xsl:if test="epj1:HensynVedForskrivning = 'false' or epj1:HensynVedForskrivning = '0'">Nei</xsl:if>
								</td>
								<td>
									<xsl:if test="epj1:HensynMatDrikke = 'true' or epj1:HensynMatDrikke = '1'">Ja</xsl:if>
									<xsl:if test="epj1:HensynMatDrikke = 'false' or epj1:HensynMatDrikke = '0'">Nei</xsl:if>
								</td>
								<td>
									<xsl:if test="epj1:Kontaktallergi = 'true' or epj1:Kontaktallergi = '1'">Ja</xsl:if>
									<xsl:if test="epj1:Kontaktallergi = 'false' or epj1:Kontaktallergi = '0'">Nei</xsl:if>
								</td>
								<td>
									<xsl:if test="epj1:PollenInnsektstikk = 'true' or epj1:PollenInnsektstikk = '1'">Ja</xsl:if>
									<xsl:if test="epj1:PollenInnsektstikk = 'false' or epj1:PollenInnsektstikk = '0'">Nei</xsl:if>
								</td>
								<td>
									<xsl:value-of select="epj1:VirkestoffLegemiddel/@DN"/>
								</td>
								<td>
									<xsl:value-of select="epj1:KodeAnnetStoff/@DN"/>
								</td>
							</tr>-->
						</xsl:for-each>
						<xsl:if test="epj2:Journaltekst">
							<tr>
								<td colspan="4">
									<xsl:apply-templates select="epj2:Journaltekst"/>
								</td>
							</tr>
						</xsl:if>
					</xsl:for-each>
				</tbody>
			</table>
		</div>
	</xsl:template>
	<xsl:template match="epj1:Allerginotat">
		<xsl:if test="not((preceding-sibling::epj1:Allerginotat) and (preceding-sibling::epj1:Cave) )">
			<!--<h3>Allergier</h3>-->
		</xsl:if>
		<table width="100%" border="0">
			<xsl:apply-templates select="epj1:Allergi"/>
			<xsl:if test="epj2:Journaltekst">
				<tr>
					<td colspan="5">
						<xsl:apply-templates select="epj2:Journaltekst"/>
					</td>
				</tr>
			</xsl:if>
		</table>
	</xsl:template>
	<xsl:template match="epj1:Allergi">
		<tr>
			<td width="20%">
				<b>Allergisk mot</b>
			</td>
			<td width="80%" colspan="4">
				<xsl:value-of select="epj1:AllergiskMot"/>
			</td>
		</tr>
		<tr>
			<td width="20%"/>
			<td width="20%">Hensyn ved forskrivning:&#160;<xsl:if test="epj1:HensynVedForskrivning = 'true' or epj1:HensynVedForskrivning = '1'">
					<b>Ja</b>
				</xsl:if>
				<xsl:if test="epj1:HensynVedForskrivning = 'false' or epj1:HensynVedForskrivning = '0'">Nei</xsl:if>
			</td>
			<td width="20%">Hensyn til mat og drikke:&#160;<xsl:if test="epj1:HensynMatDrikke = 'true' or epj1:HensynMatDrikke = '1'">
					<b>Ja</b>
				</xsl:if>
				<xsl:if test="epj1:HensynMatDrikke = 'false' or epj1:HensynMatDrikke = '0'">Nei</xsl:if>
			</td>
			<td width="20%">Kontaktallergi:&#160;<xsl:if test="epj1:Kontaktallergi = 'true' or epj1:Kontaktallergi = '1'">
					<b>Ja</b>
				</xsl:if>
				<xsl:if test="epj1:Kontaktallergi = 'false' or epj1:Kontaktallergi = '0'">Nei</xsl:if>
			</td>
			<td width="20%">Pollen/innsektsstikk:&#160;<xsl:if test="epj1:PollenInnsektstikk = 'true' or epj1:PollenInnsektstikk = '1'">
					<b>Ja</b>
				</xsl:if>
				<xsl:if test="epj1:PollenInnsektstikk = 'false' or epj1:PollenInnsektstikk = '0'">Nei</xsl:if>
			</td>
		</tr>
		<xsl:if test="epj1:VirkestoffLegemiddel or epj1:KodeAnnetStoff or epj1:AnafylaktiskeReaksjoner">
			<tr>
				<td width="20%"/>
				<xsl:choose>
					<xsl:when test="epj1:VirkestoffLegemiddel">
						<td >Virkestoff i legemiddel:&#160;<xsl:value-of select="epj1:VirkestoffLegemiddel/@DN"/></td>
					</xsl:when>
					<xsl:otherwise>
						<td></td>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="epj1:KodeAnnetStoff">
						<td >Kode for annet stoff:&#160;<xsl:value-of select="epj1:KodeAnnetStoff/@DN"/>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td></td>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="epj1:AnafylaktiskeReaksjoner">
						<td >Anafylaktiske reaksjoner:&#160;<xsl:value-of select="epj1:AnafylaktiskeReaksjoner/@DN"/>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td></td>
					</xsl:otherwise>
				</xsl:choose>
				<td></td>
			</tr>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
