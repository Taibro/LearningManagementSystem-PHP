<?php

namespace App\Http\Controllers;

use App\Models\TeamInvitation;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class DashboardController extends Controller
{
    #[OA\Get(
        path: '/api/{current_team}/dashboard',
        operationId: 'getTeamDashboard',
        tags: ['Dashboard'],
        summary: 'Get team dashboard data',
        description: 'Returns team dashboard including pending invitations for the authenticated user',
        security: [['bearerAuth' => []]],
        parameters: [
            new OA\Parameter(name: 'current_team', in: 'path', required: true, description: 'Current Team ID or slug', schema: new OA\Schema(type: 'string')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Dashboard data retrieved successfully'),
            new OA\Response(response: 401, description: 'Unauthenticated'),
            new OA\Response(response: 403, description: 'Unauthorized team membership'),
        ]
    )]
    public function __invoke(Request $request): \Illuminate\Http\JsonResponse
    {
        $email = strtolower($request->user()->email);

        $pendingInvitations = TeamInvitation::query()
            ->with(['inviter', 'team'])
            ->whereRaw('LOWER(email) = ?', [$email])
            ->whereNull('accepted_at')
            ->where(fn ($query) => $query
                ->whereNull('expires_at')
                ->orWhere('expires_at', '>=', now()))
            ->latest()
            ->get()
            ->map(fn (TeamInvitation $invitation) => [
                'code' => $invitation->code,
                'inviterName' => $invitation->inviter->name,
                'team' => [
                    'name' => $invitation->team->name,
                    'slug' => $invitation->team->slug,
                ],
            ]);

        return response()->json([
            'pendingInvitations' => $pendingInvitations,
        ]);
    }
}
