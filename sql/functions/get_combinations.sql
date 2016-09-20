create or replace function get_combinations(max int, size int) RETURNS  TABLE( bit_comb bit) as $$
declare source int[]='{}';
begin
IF NOT EXISTS (SELECT 1 FROM cc WHERE ith_combination = size) THEN
  source =  array(select generate_series(0,max-1)) ;
   with recursive combinations(combination, indices) as (
   select source[i:i], array[i] from generate_subscripts(source, 1) i
   union all
   select c.combination || source[j], c.indices || j
   from   combinations c, generate_subscripts(source, 1) j
   where  j > all(c.indices) and
          array_length(c.combination, 1) < size
 )
 insert into cc (ith_combination,int_presentation) select size, (select sum(2^s) from unnest(combination) s ) from combinations
 where  array_length(combination, 1) = size;
EXECUTE 'update cc set bit_combination = int_presentation::bit('||max||') where ith_combination = '||size||'; ';
END IF;
 RETURN QUERY select bit_combination from cc where ith_combination = size and int_presentation not in (select int_presentation from processed_columns_combinations where ith_combination=size);
end
$$ language 'plpgsql' VOLATILE;