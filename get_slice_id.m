function [ slice_id ] = get_slice_id(lat, lon)
slice_id = [];
if lat >= 0 && lat < 90 && lon >= -180 && lon < -90 % A1 Zone
    slice_id = 'A1';
end
if lat >= 0 && lat < 90 && lon >= -90 && lon < 0 % B1 Zone
    slice_id = 'B1';
end
if lat >= 0 && lat < 90 && lon >= 0 && lon < 90 % C1 Zone
    slice_id = 'C1';
end
if lat >= 0 && lat < 90 && lon >= 90 && lon < 180 % D1 Zone
    slice_id = 'D1';
end

if lat >= -90 && lat < 0 && lon >= -180 && lon < -90 % A2 Zone
    slice_id = 'A2';
end
if lat >= -90 && lat < 0 && lon >= -90 && lon < 0 % B2 Zone
    slice_id = 'B2';
end
if lat >= -90 && lat < 0 && lon >= 0 && lon < 90 % C2 Zone
    slice_id = 'C2';
end
if lat >= -90 && lat < 0 && lon >= 90 && lon < 180 % D2 Zone
    slice_id = 'D2';
end
end