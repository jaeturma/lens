<?php

namespace App\Enums;

/**
 * The full vocabulary WP-06-02 (attendance) and WP-06-03 (announcements)
 * create notifications for — defined now since "type" is this package's
 * own scope item, matching the AttendanceRule precedent (WP-04-01) of
 * building fields later work packages populate.
 */
enum NotificationType: string
{
    case Arrival = 'arrival';
    case Departure = 'departure';
    case Late = 'late';
    case Absence = 'absence';
    case Correction = 'correction';
    case AnnouncementPublished = 'announcement_published';
}
