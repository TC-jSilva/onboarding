# -*- perl -*-
package mod::job::edit;

use strict 'vars';
use Exporter;

use mod::main;
use mod::db;
use mod::error;
use mod::text::text;
use mod::user::query;

use vars qw(@ISA @EXPORT);
@ISA    = qw(Exporter);
@EXPORT = qw(insert_job update_job update_job_time delete_jobs insert_job_days
  delete_job_day insert_job_day_types restore_def_day_types_job
  delete_job_day_types insert_job_skills delete_job_skills
  insert_job_provider_types delete_job_provider_types verify_job
  verify_job_skills verify_job_days delete_job_schedule_dates delete_job_providers
  delete_job_holiday_history delete_job_events);

sub insert_job {
    my ($cgi_vars)=@_;
    my ($jobid, $providers);

    report_error('need more values to create a job',
		 'need more values to create a job')
	unless $cgi_vars->{'groupid'} and $cgi_vars->{'job_typeid'} and
	    $cgi_vars->{'name'} and $cgi_vars->{'abbrev'};

    $jobid=get_new_id('job');
    my $tigerconnect_integration = 0;
    if($cgi_vars->{'tigerconnect_integration'} == 1) {
        $tigerconnect_integration = 1;
    }

    my $show_empty_assignments = 0;
    if($cgi_vars->{'show_empty_assignments'} == 1) {
        $show_empty_assignments = 1;
    }

    my $overnight_float = 0;
    if($cgi_vars->{'overnight_float'} == 1) {
        $overnight_float = 1;
    }

    my $overnight_call = 0;
    if($cgi_vars->{'overnight_call'} == 1) {
        $overnight_call = 1;
    }

    modify_table('could not insert new scheduler',
        q(INSERT INTO job (jobid, job_typeid, groupid, facilityid, name,
           abbrev, priority, show_empty_assignments, overnight_float, overnight_call,
           tigerconnect_integration, tigerconnect_role_token)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)), $jobid, $cgi_vars->{'job_typeid'},
        $cgi_vars->{'groupid'}, $cgi_vars->{'facilityid'}, $cgi_vars->{'name'},
        $cgi_vars->{'abbrev'}, $cgi_vars->{'priority'}, $show_empty_assignments, $overnight_float, $overnight_call,
        $tigerconnect_integration, $cgi_vars->{'tigerconnect_role_token'}
    );

    # default for all providers
    modify_table('could not default new job for providers',
		 q(INSERT INTO provider2job (providerid, jobid)
		   SELECT p.providerid, ?
		   FROM users u, groups g, provider p
		   WHERE g.groupid=? AND
		   g.groupid=p.groupid AND
		   u.userid=p.userid), $jobid, $cgi_vars->{'groupid'});

    #update filter timestamp we can immediately see this new job
    #2006-07-25 jason.gaetz
    modify_table('could not update filter_timestamp',
	q(UPDATE groups set filter_timestamp=now() WHERE groupid=?),
	$cgi_vars->{'groupid'});


    return $jobid;
}

sub delete_jobs {
    my ($cgi_vars)=@_;
    if(get_user_typeid() > 5) {
        # only trainers should be here
        $main::CGI->redirect($ENV{'SCRIPT_NAME'});

	exit;
    }

    foreach (keys(%$cgi_vars)) {
	next unless $_=~/^job(\d+)$/ig;
	delete_job_schedule_dates($1);
	delete_job_providers($1);
	delete_job_skills($1);
	delete_job_day_types($1);
	delete_job_provider_types($1);
	delete_job_holiday_history($1);
	delete_job_events($1);
  delete_job_notifications($1);

	modify_table('could not delete job',
		     q(DELETE FROM job WHERE jobid=?), $1);
    }
    return 1;
}

sub update_job {
    my ($cgi_vars)=@_;

    my $tigerconnect_integration = 0;
    if($cgi_vars->{'tigerconnect_integration'} == 1) {
        $tigerconnect_integration = 1;
    }

    my $show_empty_assignments = 0;
    if($cgi_vars->{'show_empty_assignments'} == 1) {
        $show_empty_assignments = 1;
    }

    my $overnight_float = 0;
    if($cgi_vars->{'overnight_float'} == 1) {
        $overnight_float = 1;
    }

    my $overnight_call = 0;
    if($cgi_vars->{'overnight_call'} == 1) {
        $overnight_call = 1;
    }

warn 'updating job';
    modify_table('could not update job',
        q(UPDATE job SET name=?, abbrev=?, priority=?, job_typeid=?, show_empty_assignments=?, overnight_float=?,
            overnight_call=?, facilityid=?, tigerconnect_integration=?, tigerconnect_role_token=? WHERE jobid=?),
        $cgi_vars->{'name'}, $cgi_vars->{'abbrev'}, $cgi_vars->{'priority'},
        $cgi_vars->{'job_typeid'}, $show_empty_assignments, $overnight_float, $overnight_call,
        $cgi_vars->{'facilityid'}, $tigerconnect_integration, $cgi_vars->{'tigerconnect_role_token'},
        $cgi_vars->{'jobid'}
    );

    update_notifications_for_job($cgi_vars->{'jobid'});

    return 1;
}

sub update_job_time {
    my ($cgi_vars)=@_;
    my ($start_time, $end_time);

    $start_time=$cgi_vars->{'start_hour'}.':'.$cgi_vars->{'start_minute'}.' '.$cgi_vars->{'start_am_pm'};
    $end_time=$cgi_vars->{'end_hour'}.':'.$cgi_vars->{'end_minute'}.' '.$cgi_vars->{'end_am_pm'};

    modify_table('could not update times',
		 q(UPDATE job SET starttime=?, endtime=? WHERE jobid=?),
		 $start_time, $end_time, $cgi_vars->{'jobid'});

    update_notifications_for_job($cgi_vars->{'jobid'});

    return 1;
}

sub insert_job_days {
    my ($cgi_vars)=@_;

    modify_table('could not delete unused days for job',
		 qq(DELETE FROM job2day_type WHERE jobid=? AND
		    dayid NOT IN ($cgi_vars->{'assigned'})),
		 $cgi_vars->{'jobid'});

    modify_table('could not insert job day link',
		 qq(INSERT INTO job2day_type (jobid, dayid, day_typeid)
		    SELECT ?, d.dayid, dt.day_typeid
		    FROM group_day_type gdt, groups g, day d, day_type dt
		    WHERE g.groupid=? AND
		    g.groupid=gdt.groupid AND
		    gdt.dayid=d.dayid AND
		    d.dayid NOT IN
		    (SELECT dayid
		     FROM job2day_type
		     WHERE jobid=? AND
		     dayid IN ($cgi_vars->{'assigned'})) AND
		    d.dayid IN ($cgi_vars->{'assigned'}) AND
		    gdt.day_typeid=dt.day_typeid),
		 $cgi_vars->{'jobid'}, $cgi_vars->{'groupid'},
		 $cgi_vars->{'jobid'});

    update_notifications_for_job($cgi_vars->{'jobid'});

    return 1;
}

sub delete_job_day {
    my ($jobid, $dayid)=@_;

    modify_table('could not delete job day(s)',
		 q(DELETE FROM job2day_type WHERE jobid=? AND dayid=?),
		 $jobid, $dayid);

    update_notifications_for_job($jobid);

    return 1;
}

sub insert_job_day_types {
    my ($cgi_vars)=@_;
    my ($key);

    foreach $key (keys(%$cgi_vars)) {
	if ($key =~ /^dayid(\d+)$/i) {
 	    modify_table('could not insert into job2day_type',
			 q(INSERT INTO job2day_type (jobid, dayid, day_typeid)
			   VALUES (?, ?, ?)), $cgi_vars->{'jobid'}, $1,
			 $cgi_vars->{$key});
        }
    }


    update_notifications_for_job($cgi_vars->{'jobid'});

    return 1;
}

sub restore_def_day_types_job {
    my ($cgi_vars)=@_;

    foreach (1..7) {
	modify_table('could not restore default day types',
		     q(UPDATE job2day_type SET day_typeid=
		       (SELECT dt.day_typeid
			FROM group_day_type gdt, groups g, day d, day_type dt
			WHERE g.groupid=? AND
			g.groupid=gdt.groupid AND
			gdt.dayid=d.dayid AND
			d.dayid=? AND
			gdt.day_typeid=dt.day_typeid)
		       WHERE jobid=? AND dayid=?),
		     $cgi_vars->{'groupid'}, $_, $cgi_vars->{'jobid'}, $_);
    }
    return 1;
}

sub delete_job_day_types {
    my ($jobid)=@_;

    modify_table('could not delete job day_types',
		 q(DELETE FROM job2day_type WHERE jobid=?), $jobid);

    update_notifications_for_job($jobid);

    return 1;
}

sub insert_job_skills {
    my ($cgi_vars)=@_;
    my (@skills);

    @skills=split /,/, $cgi_vars->{'required'};

    foreach (@skills) {
	modify_table('could not insert job skill link',
		     q(INSERT INTO job2skill (jobid, skillid) VALUES (?, ?)),
		     $cgi_vars->{'jobid'}, $_);
    }
    return 1;
}

sub delete_job_skills {
    my ($jobid)=@_;

    modify_table('could not delete job skill(s)',
		 q(DELETE FROM job2skill WHERE jobid=?), $jobid);
    return 1;
}

sub insert_job_provider_types {
    my ($cgi_vars)=@_;

    foreach (keys(%$cgi_vars)) {
	if ($_ =~ /^provider_type(\d+)$/i) {
	    modify_table('could not insert job provider_type',
			 q(INSERT INTO job2provider_type (jobid, provider_typeid)
			   VALUES (?, ?)), $cgi_vars->{'jobid'}, $1);
	}
    }
    return 1;
}

sub delete_job_provider_types {
    my ($jobid)=@_;

    modify_table('could not delete job provider_types',
		 q(DELETE FROM job2provider_type WHERE jobid=?), $jobid);
    return 1;
}

sub verify_job {
    my ($cgi_vars)=@_;
    my (@err);

    push(@err, 'Please select a valid job type')
	unless $cgi_vars->{'job_typeid'} =~ /^\d+$/;

    push(@err, 'Please give this job a priority')
	unless $cgi_vars->{'priority'} =~ /^\d+$/;

    push(@err, 'Please supply a vaild job name')
	unless $cgi_vars->{'name'};

    push(@err, 'Please supply a vaild abbreviation')
	unless $cgi_vars->{'abbrev'};

    return @err ? join('<br>', @err) : undef;

}

sub verify_job_skills {
    my ($cgi_vars)=@_;
    my (@err);

    push(@err, 'Please make sure a job is selected')
	unless $cgi_vars->{'jobid'} =~ /^\d+$/;

    push(@err, 'Please select one or more skills')
	unless $cgi_vars->{'required'};

    return @err ? join('<br>', @err) : undef;
}

sub verify_job_days {
    my ($cgi_vars)=@_;
    my (@err);

    push(@err, 'Please make sure a job is selected')
	unless $cgi_vars->{'jobid'} =~ /^\d+$/;

    push(@err, 'Please select one or more days')
	unless $cgi_vars->{'assigned'};

    return @err ? join('<br>', @err) : undef;
}

sub delete_job_events {
    my $jobid=shift;
    modify_table('could not delete job events',
		 q(DELETE FROM tally WHERE jobid=?), $jobid);

    modify_table('could not delete job events',
		 q(DELETE FROM event WHERE jobid=?), $jobid);

    modify_table('could not delete draft mode events',
        q(DELETE FROM draft_event WHERE jobid=?), $jobid);
}

sub delete_job_holiday_history {
    modify_table('could not delete job holiday history',
		 q(DELETE FROM holiday_history WHERE jobid=?), shift);
}

sub delete_job_schedule_dates {
    modify_table('could not delete job events',
		 q(DELETE FROM schedule_date WHERE jobid=?), shift);
}

sub delete_job_providers {
    modify_table('could not delete job providers',
		 q(DELETE FROM provider2job WHERE jobid=?), shift);
}