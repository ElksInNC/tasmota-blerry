def blerry_handle(device, advert)
  var elements = advert.get_elements_by_type_length(0xFF, 0x14)
  if size(elements)
    var data = elements[0].data
    var sq = data[8] # Sequence Number 1 or 2
    var b = (data[7] & 0x7F) #Battery% - Bit 8 not used
    var pa = 1 #Label for Probe A
    var pb = 2 #Label for Probe B
   
    #Change to Probe3&4 if sequence is 2
    if sq == 2
      pa = 3
      pb = 4
    end
    

    #Add/upadte sensors
    #Battery is present in Seq1&2 but only as single value. Do it first
    device.add_sensor('Battery', b, 'battery', '%')
 
    # Loop through ProbeA & B
    for j:pa..pb
      var e = (j+1)%2 #convert probe numbers - odd > 0 and even to 1
      var f = (b*5) #offset - are we in bank A or B
      var pstat = bitval(get.data[9+f],7) # Probe inserted bit
      var palrm = bitval(get.data[9+f],6) # Probe alarming bit
      var pt = get.data[(10+f),-2] #current bank probe temp 
      var pset get.data[(12+f),-2] #current bank setppoint
      
      # Convert pstat and palrm bits to text for HA devclas binary sensor type
      if pstat 
        pstat='ON' 
      else 
        pstat='OFF'
      end
      if palrm
        palrm='ON' 
      else
        palrm='OFF'
      end
      device.add_binary_sensor('Probe'+str(j)+'_Status'	, pstat, 'plug')
      device.add_binary_sensor('Probe'+str(j)+'_Alarm'	, palrm, 'heat')

      #Set temps unless 0xFFFF - then set 'unavailable'
      if pt==0xFFFF 
        pt='unavailabe' 
      else
        pt=pt/100
      end
      device.add_sensor('Probe_'+str(j)+'_Temp', t,  'temperature', '°C')

      if pset==0xFFFF 
        pset='unavailabe' 
      else
        pset=pt/100
      end
      device.add_sensor('Probe_'+str(j)+'_Target', t,  'temperature', '°C')
    end
    return true
  else
    return false
  end
end
blerry_active = true
print('BLR: Driver: GVH5184 Loaded')
