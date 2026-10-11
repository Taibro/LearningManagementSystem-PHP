<?php

namespace App\Http\Controllers\Teams;

use App\Actions\Teams\CreateTeam;
use App\Enums\TeamRole;
use App\Http\Controllers\Controller;
use App\Http\Requests\Teams\DeleteTeamRequest;
use App\Http\Requests\Teams\SaveTeamRequest;
use App\Models\Membership;
use App\Models\Team;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;


class TeamController extends Controller
{
    /**
     * Display a listing of the user's teams.
     */
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'teams' => $user->toUserTeams(includeCurrent: true),
        ]);
    }

    /**
     * Store a newly created team.
     */
    public function store(SaveTeamRequest $request, CreateTeam $createTeam): \Illuminate\Http\JsonResponse
    {
        $team = $createTeam->handle($request->user(), $request->validated('name'));

        return response()->json(['message' => __('Team created.'), 'team' => $team->slug]);
    }

    /**
     * Show the team edit page.
     */
    public function edit(Request $request, Team $team): \Illuminate\Http\JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'team' => [
                'id' => $team->id,
                'name' => $team->name,
                'slug' => $team->slug,
                'isPersonal' => $team->is_personal,
            ],
            'members' => $team->members()->get()->map(function (User $member) {
                /** @var Membership $membership */
                $membership = $member->getRelation('pivot');

                return [
                    'id' => $member->id,
                    'name' => $member->name,
                    'email' => $member->email,
                    'avatar' => $member->avatar ?? null,
                    'role' => $membership->role->value,
                    'role_label' => $membership->role->label(),
                ];
            }),
            'invitations' => $team->invitations()
                ->whereNull('accepted_at')
                ->get()
                ->map(fn ($invitation) => [
                    'code' => $invitation->code,
                    'email' => $invitation->email,
                    'role' => $invitation->role->value,
                    'role_label' => $invitation->role->label(),
                    'created_at' => $invitation->created_at->toISOString(),
                ]),
            'permissions' => $user->toTeamPermissions($team),
            'availableRoles' => TeamRole::assignable(),
        ]);
    }

    /**
     * Update the specified team.
     */
    public function update(SaveTeamRequest $request, Team $team): \Illuminate\Http\JsonResponse
    {
        Gate::authorize('update', $team);

        $team = DB::transaction(function () use ($request, $team) {
            $team = Team::whereKey($team->id)->lockForUpdate()->firstOrFail();

            $team->update(['name' => $request->validated('name')]);

            return $team;
        });

        return response()->json(['message' => __('Team updated.'), 'team' => $team->slug]);
    }

    /**
     * Switch the user's current team.
     */
    public function switch(Request $request, Team $team): \Illuminate\Http\JsonResponse
    {
        abort_unless($request->user()->belongsToTeam($team), 403);

        $request->user()->switchTeam($team);

        return response()->json(['message' => 'Switched team']);
    }

    /**
     * Leave the specified team.
     */
    public function leave(Request $request, Team $team): \Illuminate\Http\JsonResponse
    {
        Gate::authorize('leave', $team);

        $user = $request->user();

        $fallbackTeam = $user->isCurrentTeam($team)
            ? $user->fallbackTeam($team)
            : null;

        $team->memberships()
            ->where('user_id', $user->id)
            ->delete();

        if ($fallbackTeam) {
            $user->switchTeam($fallbackTeam);
        }

        return response()->json(['message' => __('You left the team ":name"', ['name' => $team->name])]);
    }

    /**
     * Delete the specified team.
     */
    public function destroy(DeleteTeamRequest $request, Team $team): \Illuminate\Http\JsonResponse
    {
        $user = $request->user();
        $fallbackTeam = $user->isCurrentTeam($team)
            ? $user->fallbackTeam($team)
            : null;

        DB::transaction(function () use ($user, $team) {
            User::where('current_team_id', $team->id)
                ->where('id', '!=', $user->id)
                ->each(fn (User $affectedUser) => $affectedUser->switchTeam($affectedUser->personalTeam()));

            $team->invitations()->delete();
            $team->memberships()->delete();
            $team->delete();
        });

        if ($fallbackTeam) {
            $user->switchTeam($fallbackTeam);
        }

        return response()->json(['message' => __('Team deleted.')]);
    }
}
