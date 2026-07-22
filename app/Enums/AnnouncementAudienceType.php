<?php

namespace App\Enums;

enum AnnouncementAudienceType: string
{
    case All = 'all';
    case Grade = 'grade';
    case Section = 'section';
    case Students = 'students';
}
