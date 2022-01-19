def blerry_handle(device, advert)
  var elements = advert.get_elements_by_type_length(0xFF, 0x14)
  if size(elements)
    var data = elements[0].data

    # Probes 1 & 2 or 3 & 4
    var probe_labels = ['_1_', '_2_']
    if data[8] == 2
      probe_labels = ['_3_', '_4_']
    end
    
    device.add_sensor('Battery', (data[7] & 0x7F), 'battery', '%')
 
    # Loop through Probe A & B
    for probe_idx:0..1
      var probe_label = probe_labels[probe_idx]
      var offset = 5*probe_idx
      device.add_binary_sensor('Probe' + probe_label + 'Status', blerry_helpers.bitval(data[offset + 9], 7), 'plug') # Probe Inserted Bit
      device.add_binary_sensor('Probe' + probe_label + 'Alarm',  blerry_helpers.bitval(data[offset + 9], 6), 'heat') # Probe Alarming Bit

      var probe_t = data.get(offset + 10, -2)
      if probe_t == 0xFFFF
        probe_t = 'unavailable'
      else
        probe_t = probe_t/100.0
      end
      device.add_sensor('Probe' + probe_label + 'Temp', probe_t,  'temperature', '°C')

      var probe_set = data.get(offset + 12, -2)
      if probe_set == 0xFFFF 
        probe_set = 'unavailable' 
      else
        probe_set = probe_set/100.0
      end
      device.add_sensor('Probe' + probe_label + 'Target', probe_set,  'temperature', '°C')
    end
    return true
  else
    return false
  end
end
blerry_active = false
print('BLR: Driver: GVH5184 Loaded')
