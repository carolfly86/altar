create or replace function sober_score(passed_cnt numeric, total_passed_cnt numeric,failed_cnt numeric, total_failed_cnt numeric) 
RETURNS  float as $$
declare
	similarity float;
	avgF float;
	avgP float;
	varP float;
begin
 if total_failed_cnt > 0 then
	 avgF := failed_cnt/total_failed_cnt;
	 avgP := passed_cnt/total_passed_cnt;
	 varP := sqrt(((1-avgP)^2*passed_cnt + (avgP)^2*(total_passed_cnt-passed_cnt))/(total_passed_cnt-1));
	 if varP >0 then 
	 	similarity :=LOG(exp(1.0)::numeric,(varP*sqrt(2*pi()/total_failed_cnt))::numeric)+(total_failed_cnt*(avgF-avgP)^2)/(2*varP);
	 else
	 	similarity :=null;
	 end if;
 else
 	similarity :=-99999;
 end if;
 RETURN similarity;
end
$$ language 'plpgsql' VOLATILE;