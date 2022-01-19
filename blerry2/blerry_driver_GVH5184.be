def blerry_handle(device, advert)
  var elements = advert.get_elements_by_type_length(0xFF, 0x14)
  if size(elements)
    var data = elements[0].data
    var sq = data[8] # Sequence Number 1 or 2
    var b = (data[7] & 0x7F) #Battery% - Bit 8 not used
    var pa = 1 #Label for Probe A
    var pb = 2 #Label for Probe B
    print('gvh5184-1')

    #Change to Probe3&4 if sequence is 2
    if sq == 2
      pa = 3
      pb = 4
    end
    

    #Add/upadte sensors
    #Battery is present in Seq1&2 but only as single value. Do it first
    device.add_sensor('Battery', b, 'battery', '%')
    print('gvh5184-2')
 
    # Loop through ProbeA & B
    for j:pa..pb
      print("j: ",j)
      var e = (j+1)%2 #convert probe numbers - odd > 0 and even to 1
      print("e: ",e)
      var f = (e*5) #offset - are we in bank A or B
      print("f: ",f)
      print('gvh5184-3')
      var pstat = blerry_helpers.bitval(data.get((9+f),-1),7) # Probe inserted bit
      print('pstat-pre: ',pstat)
      print('gvh5184-3')
      var palrm = blerry_helpers.bitval(data.get((9+f),-1),6) # Probe alarming bit
      print('palrm-pre: ',palrm)
      var pt = data.get((10+f),-2) #current bank probe temp 
      print('pt-pre: ',pt)
      var pset = data.get((12+f),-2) #current bank setppoint
      print('pset-pre: ',pset)
      print('gvh5184-4')

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
      print('gvh5184-5')
      print('pstat: ',pstat)
      device.add_binary_sensor('Probe'+str(j)+'_Status'	, pstat, 'plug')
      print('palarm: ',palrm)
      device.add_binary_sensor('Probe'+str(j)+'_Alarm'	, palrm, 'heat')

      #Set temps unless 0xFFFF - then set 'unavailable'
      if pt==0xFFFF 
        pt='unavailabe' 
      else
        pt=pt/100
      end
      print('pt: ',pt)
      device.add_sensor('Probe_'+str(j)+'_Temp', pt,  'temperature', '°C')
      print('gvh5184-6')
      
      if pset==0xFFFF 
        pset='unavailabe' 
      else
        pset=pset/100
      end
      print('pset: ',pset)
      device.add_sensor('Probe_'+str(j)+'_Target', pset,  'temperature', '°C')
      print('gvh5184-7')

    end
    return true
    print('gvh5184-8')
  else
    return false
  end
end
blerry_active = false
print('BLR: Driver: GVH5184 Loaded')
