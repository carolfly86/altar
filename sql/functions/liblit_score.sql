create or replace function liblit_score(passed_cnt numeric, total_passed_cnt numeric,failed_cnt numeric, total_failed_cnt numeric) 
RETURNS  float as $$
declare
	importance float;
	failure float;
	increase float;
	context float;
begin
 if failed_cnt + passed_cnt >0 then
  	failure := failed_cnt/(failed_cnt + passed_cnt);
  	context := total_failed_cnt/(total_passed_cnt + total_failed_cnt);
  	increase := failure-context;
 else
 	increase := 0;
 end if;

 if increase !=0 then 
 	if failed_cnt >0 then
 		if failed_cnt =1 then
 		  importance := 0;
 		else
	   		importance := 2/(1/increase + log(exp(1.0),total_failed_cnt)/log(exp(1.0),failed_cnt));
		end if;
		--importance := 2/(1/increase + log(exp(1.0),(total_failed_cnt-failed_cnt)));
	else
		importance := 2*increase;
	end if;
 else
	importance := increase;
 end if;
 RETURN importance;
end
$$ language 'plpgsql' VOLATILE;

