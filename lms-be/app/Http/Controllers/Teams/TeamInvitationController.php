<?php

namespace App\Http\Controllers\Teams;

use App\Enums\TeamRole;
use App\Http\Controllers\Controller;
use App\Http\Requests\Teams\CreateTeamInvitationRequest;
use App\Http\Requests\Teams\RespondToTeamInvitationRequest;
use App\Models\Team;
use App\Models\TeamInvitation;
use App\Notifications\Teams\TeamInvitation as TeamInvitationNotification;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Notification;

class TeamInvitationController extends Controller
{
    /**
     * Store a newly created invitation.
     */
    public function store(CreateTeamInvitationRequest $request, Team $team): \Illuminate\Http\JsonResponse
    {
        Gate::authorize('inviteMember', $team);

        $invitation = $team->invitations()->create([
            'email' => $request->validated('email'),
            'role' => TeamRole::from($request->validated('role')),
            'invited_by' => $request->user()->id,
            'expires_at' => now()->addDays(3),
        ]);

        Notification::route('mail', $invitation->email)
            ->notify(new TeamInvitationNotification($invitation));

        return response()->json(['message' => __('Invitation sent.')]);
    }

    /**
     * Cancel the specified invitation.
     */
    public function destroy(Team $team, TeamInvitation $invitation): \Illuminate\Http\JsonResponse
    {
        abort_unless($invitation->team_id === $team->id, 404);

        Gate::authorize('cancelInvitation', $team);

        $invitation->delete();

        return response()->json(['message' => __('Invitation cancelled.')]);
    }

    /**
     * Accept the invitation.
     */
    public function accept(RespondToTeamInvitationRequest $request, TeamInvitation $invitation): \Illuminate\Http\JsonResponse
    {
        $user = $request->user();

        DB::transaction(function () use ($user, $invitation) {
            $team = $invitation->team;

            $team->memberships()->firstOrCreate(
                ['user_id' => $user->id],
                ['role' => $invitation->role],
            );

            $invitation->update(['accepted_at' => now()]);

            $user->switchTeam($team);
        });

        return response()->json(['message' => __('Invitation accepted.')]);
    }

    /**
     * Decline the invitation.
     */
    public function decline(RespondToTeamInvitationRequest $request, TeamInvitation $invitation): \Illuminate\Http\JsonResponse
    {
        $invitation->delete();

        return response()->json(['message' => __('Invitation declined.')]);
    }
}
